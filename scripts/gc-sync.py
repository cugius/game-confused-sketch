#!/usr/bin/env python3
"""Reconcile Game Center metadata and artwork; dry-run by default, --apply writes.
Uses the v1 App Store Connect endpoints already used by this project. Local validation
needs no Apple credentials. No builds, review submissions or score resets are performed.
"""
import argparse, base64, hashlib, json, os, time
from pathlib import Path
from urllib.parse import urlparse
ROOT=Path(__file__).resolve().parents[1]
LOCALES={'it':'it','en':'en-US','es':'es-ES','fr':'fr-FR','de':'de-DE','ja':'ja'}
API='https://api.appstoreconnect.apple.com'
class APIError(RuntimeError):
    def __init__(self,status,detail):self.status=status;super().__init__(f'Apple HTTP {status}: {detail}')
class Client:
    def request(self,method,path,**kw):
        import jwt,requests
        now=int(time.time())
        token=jwt.encode({'iss':os.environ['ASC_ISSUER_ID'],'iat':now,'exp':now+900,'aud':'appstoreconnect-v1'},Path(os.environ['ASC_KEY_PATH']).read_bytes(),algorithm='ES256',headers={'kid':os.environ['ASC_KEY_ID']})
        url=path if path.startswith('https://') else API+path
        if urlparse(url).netloc!='api.appstoreconnect.apple.com':raise ValueError('Unexpected pagination host')
        for attempt in range(5):
            try:r=requests.request(method,url,headers={'Authorization':'Bearer '+token},timeout=(20,90),**kw)
            except requests.RequestException:raise RuntimeError(f'Apple connection failed during {method} {urlparse(url).path}') from None
            if r.status_code==429 or (method=='GET' and r.status_code>=500):time.sleep(min(30,2**attempt));continue
            if not r.ok:
                try:detail='; '.join(e.get('detail',e.get('title','')) for e in r.json().get('errors',[]))
                except ValueError:detail='Non-JSON response'
                raise APIError(r.status_code,detail)
            return r.json() if r.content else {}
        raise RuntimeError('Apple request remained unavailable')
    def listing(self,path):
        result=[]
        while path:
            page=self.request('GET',path);result+=page.get('data',[]);path=page.get('links',{}).get('next')
        return result
    def optional(self,path):
        try:return self.request('GET',path).get('data')
        except APIError as e:
            if e.status==404:return None
            raise

def validate():
    from PIL import Image
    d=json.loads((ROOT/'assets/gamecenter/definitions.json').read_text())
    assert len(d['achievements'])==44 and sum(a['points'] for a in d['achievements'])==945 and len(d['leaderboards'])==3
    seen=set();hashes=set()
    manifest={a['id']:a for a in json.loads((ROOT/'assets/gamecenter/images/manifest.json').read_text())}
    for kind in ('achievements','leaderboards'):
        for a in d[kind]:
            assert a['id'] not in seen;seen.add(a['id']);assert a['id'].startswith('cs.')
            assert set(a['names'])==set(LOCALES)
            if kind=='achievements':assert set(a['descriptions'])==set(LOCALES) and 0<a['points']<=100
            for value in a['names'].values():assert 0<len(value)<=100
            p=ROOT/'assets/gamecenter/images'/f'{a["id"]}.png';im=Image.open(p)
            assert im.size==(1024,1024) and im.mode=='RGB'
            digest=hashlib.sha256(p.read_bytes()).hexdigest();hashes.add(digest)
            assert manifest[a['id']]['sha256']==digest
    assert len(seen)==47 and len(hashes)==47 and len(manifest)==47
    im=Image.open(ROOT/'ios/ConfusedSketch/Assets.xcassets/AppIcon.appiconset/AppIcon.png')
    assert im.size==(1024,1024) and im.mode=='RGB'
    print('Local validation passed: icon + 47 distinct Game Center images; six locales; 945 points.')
    return d
class Sync:
    def __init__(self,client,apply=False):self.client=client;self.apply=apply;self.ready=0;self.uploaded=0
    def create(self,kind,attrs,relation,parent_kind,parent_id):
        return self.client.request('POST',f'/v1/{kind}',json={'data':{'type':kind,'attributes':attrs,'relationships':{relation:{'data':{'type':parent_kind,'id':parent_id}}}}})['data']
    def artwork(self,prefix,localization,path):
        image_type=prefix+'Images';locale_type=prefix+'Localizations';raw=path.read_bytes()
        filename=f'{path.stem}-{hashlib.sha256(raw).hexdigest()[:16]}.png'
        image=self.client.optional(f'/v1/{locale_type}/{localization}/{prefix}Image')
        state=(image or {}).get('attributes',{}).get('assetDeliveryState',{}).get('state')
        if image and image['attributes'].get('fileName')==filename and state=='COMPLETE':self.ready+=1;return
        if not self.apply:print(f'  image pending: {path.stem}');return
        if image and (image['attributes'].get('fileName')!=filename or state=='FAILED'):
            self.client.request('DELETE',f'/v1/{image_type}/{image["id"]}');image=None;state=None
        if not image:image=self.create(image_type,{'fileName':filename,'fileSize':len(raw)},prefix+'Localization',locale_type,localization)
        iid=image['id'];attrs=image['attributes'];state=attrs.get('assetDeliveryState',{}).get('state')
        if state not in ('UPLOAD_COMPLETE','IN_PROGRESS','COMPLETE'):
            import requests
            ops=attrs.get('uploadOperations') or []
            if not ops:raise RuntimeError(f'No upload operations for {path.stem}')
            for op in ops:
                chunk=raw[op['offset']:op['offset']+op['length']]
                assert len(chunk)==op['length'] and urlparse(op['url']).scheme=='https'
                headers={h['name']:h['value'] for h in op.get('requestHeaders',[])}
                # Signed asset URLs receive no App Store Connect bearer token.
                for attempt in range(4):
                    try:
                        r=requests.request(op['method'],op['url'],headers=headers,data=chunk,timeout=(20,120))
                        if r.ok:break
                    except requests.RequestException:pass
                    if attempt==3:raise RuntimeError(f'Upload failed: {path.stem}')
                    time.sleep(2**attempt)
            self.client.request('PATCH',f'/v1/{image_type}/{iid}',json={'data':{'type':image_type,'id':iid,'attributes':{'uploaded':True}}});self.uploaded+=1
        for _ in range(30):
            attrs=self.client.request('GET',f'/v1/{image_type}/{iid}')['data']['attributes'];state=attrs.get('assetDeliveryState',{}).get('state')
            if state=='COMPLETE':self.ready+=1;return
            if state=='FAILED':raise RuntimeError(f'Apple rejected {path.stem}: {attrs.get("assetDeliveryState")}')
            time.sleep(2)
        raise RuntimeError(f'Apple is still processing {path.stem}; rerun to resume')
    def run(self,detail,defs):
        for kind,prefix in [('achievements','gameCenterAchievement'),('leaderboards','gameCenterLeaderboard')]:
            resource_type=prefix+'s';locale_type=prefix+'Localizations'
            existing={a['attributes']['vendorIdentifier']:a for a in self.client.listing(f'/v1/gameCenterDetails/{detail}/{resource_type}?limit=200')}
            for item in defs[kind]:
                vid=item['id'];print(f'{kind}: {vid}',flush=True);resource=existing.get(vid)
                if not resource:
                    if not self.apply:print('  create metadata, six localizations and six images');continue
                    attrs={'referenceName':item['names']['en'],'vendorIdentifier':vid}
                    if kind=='achievements':attrs.update(points=item['points'],showBeforeEarned=True,repeatable=False)
                    else:attrs.update(defaultFormatter='INTEGER',submissionType='BEST_SCORE',scoreSortType='DESC')
                    resource=self.create(resource_type,attrs,'gameCenterDetail','gameCenterDetails',detail)
                elif kind=='achievements' and resource['attributes'].get('points')!=item['points']:
                    raise RuntimeError(f'Existing points mismatch for {vid}; inspect before changing live points')
                rid=resource['id'];locales={a['attributes']['locale']:a for a in self.client.listing(f'/v1/{resource_type}/{rid}/{locale_type}?limit=200')}
                for lang,locale in LOCALES.items():
                    attrs={'name':item['names'][lang]}
                    if kind=='achievements':attrs.update(beforeEarnedDescription=item['descriptions'][lang],afterEarnedDescription=item['descriptions'][lang])
                    loc=locales.get(locale)
                    if not loc:
                        if not self.apply:print(f'  locale pending: {locale}');continue
                        loc=self.create(locale_type,dict(attrs,locale=locale),prefix,resource_type,rid)
                    elif any(loc['attributes'].get(k)!=v for k,v in attrs.items()):
                        print(f'  update locale {locale}')
                        if self.apply:self.client.request('PATCH',f'/v1/{locale_type}/{loc["id"]}',json={'data':{'type':locale_type,'id':loc['id'],'attributes':attrs}})
                    self.artwork(prefix,loc['id'],ROOT/'assets/gamecenter/images'/f'{vid}.png')
        if self.apply and self.ready!=282:raise RuntimeError(f'Incomplete image delivery: {self.ready}/282 localizations')
        print(f'Images ready on Apple: {self.ready}/282; new uploads: {self.uploaded}; apply={self.apply}')
        if os.environ.get('GC_REPORT_PATH'):
            Path(os.environ['GC_REPORT_PATH']).write_text(json.dumps({'apply':self.apply,'images_ready':self.ready,'expected_localized_images':282,'new_uploads':self.uploaded},indent=2)+'\n')

def gamecenter_detail(client,app_id,apply):
    detail=client.optional(f'/v1/apps/{app_id}/gameCenterDetail')
    if detail or not apply:return detail
    # Enable the missing app-level detail only during an explicit --apply run.
    return client.request('POST','/v1/gameCenterDetails',json={'data':{'type':'gameCenterDetails','relationships':{'app':{'data':{'type':'apps','id':app_id}}}}})['data']

def main():
    p=argparse.ArgumentParser();p.add_argument('--apply',action='store_true');p.add_argument('--validate-only',action='store_true');args=p.parse_args()
    d=validate()
    if args.validate_only:return
    c=Client();apps=c.listing('/v1/apps?filter[bundleId]=com.confusedbyme.confusedsketch&limit=2')
    if len(apps)!=1:raise RuntimeError('Expected one Confused Sketch app accessible to the API key')
    detail=gamecenter_detail(c,apps[0]['id'],args.apply)
    if not detail:
        report={'apply':False,'gamecenter_enabled':False,'images_ready':0,'expected_localized_images':282,'new_uploads':0,'next_action':'Run Game Center sync with apply=true to enable and populate Game Center'}
        print(json.dumps(report,indent=2))
        if os.environ.get('GC_REPORT_PATH'):Path(os.environ['GC_REPORT_PATH']).write_text(json.dumps(report,indent=2)+'\n')
        return
    Sync(c,args.apply).run(detail['id'],d)
if __name__=='__main__':main()
