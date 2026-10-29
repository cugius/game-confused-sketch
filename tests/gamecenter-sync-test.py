import importlib.util, hashlib, json, unittest
from unittest.mock import patch
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('gc_sync',ROOT/'scripts/gc-sync.py');gc=importlib.util.module_from_spec(spec);spec.loader.exec_module(gc)
class FakeClient:
    def __init__(self,defs,missing=False):self.defs=defs;self.missing=missing;self.writes=[]
    def listing(self,path):
        if 'gameCenterDetails/' in path:
            kind='achievements' if 'Achievements' in path else 'leaderboards'
            return [{'id':a['id'],'attributes':{'vendorIdentifier':a['id'],**({'points':a['points']} if kind=='achievements' else {})}} for a in self.defs[kind]]
        rid=path.split('/')[3];a=next(a for kind in self.defs.values() if isinstance(kind,list) for a in kind if a['id']==rid)
        return [{'id':rid+':'+locale,'attributes':{'locale':locale,'name':a['names'][lang],**({'beforeEarnedDescription':a['descriptions'][lang],'afterEarnedDescription':a['descriptions'][lang]} if 'descriptions' in a else {})}} for lang,locale in gc.LOCALES.items() if not(self.missing and rid=='cs.first_wave' and lang=='en')]
    def request(self,method,path,**kwargs):
        self.writes.append((method,path,kwargs));data=kwargs['json']['data'];return {'data':{'id':'recovered-en','attributes':data['attributes']}}
class CatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):cls.defs=json.loads((ROOT/'assets/gamecenter/definitions.json').read_text())
    def test_missing_gamecenter_detail_is_read_only_by_default(self):
        class C:
            def optional(self,path):return None
            def request(self,*a,**kw):raise AssertionError('Dry run cannot enable Game Center')
        self.assertIsNone(gc.gamecenter_detail(C(),'app-id',False))
    def test_apply_can_initialize_missing_gamecenter_detail(self):
        class C:
            def optional(self,path):return None
            def request(self,method,path,**kw):
                assert method=='POST' and path=='/v1/gameCenterDetails'
                assert kw['json']['data']['relationships']['app']['data']=={'type':'apps','id':'app-id'}
                return {'data':{'id':'new-detail'}}
        self.assertEqual(gc.gamecenter_detail(C(),'app-id',True)['id'],'new-detail')
    def test_existing_catalog_no_mutations(self):
        c=FakeClient(self.defs);s=gc.Sync(c,True)
        def ready(*a):s.ready+=1
        with patch.object(s,'artwork',side_effect=ready):s.run('detail',self.defs)
        self.assertEqual(s.ready,282);self.assertEqual(c.writes,[])
    def test_partial_localization_recovery(self):
        c=FakeClient(self.defs,missing=True);s=gc.Sync(c,True)
        def ready(*a):s.ready+=1
        with patch.object(s,'artwork',side_effect=ready):s.run('detail',self.defs)
        self.assertEqual(len(c.writes),1);self.assertEqual(c.writes[0][0],'POST')
        self.assertEqual(c.writes[0][2]['json']['data']['attributes']['locale'],'en-US')
    def test_dry_run_does_not_create_missing_locale(self):
        c=FakeClient(self.defs,missing=True);s=gc.Sync(c,False)
        with patch.object(s,'artwork'):s.run('detail',self.defs)
        self.assertEqual(c.writes,[])
    def test_completed_matching_image_skipped(self):
        p=ROOT/'assets/gamecenter/images/cs.first_wave.png';digest=hashlib.sha256(p.read_bytes()).hexdigest()[:16]
        class C:
            def optional(self,path):return {'id':'img','attributes':{'fileName':f'cs.first_wave-{digest}.png','assetDeliveryState':{'state':'COMPLETE'}}}
            def request(self,*a,**kw):raise AssertionError('Completed image must not be uploaded again')
        s=gc.Sync(C(),True);s.artwork('gameCenterAchievement','locale',p);self.assertEqual(s.ready,1)
    def test_byte_upload_does_not_forward_bearer_token(self):
        p=ROOT/'assets/gamecenter/images/cs.first_wave.png';length=len(p.read_bytes())
        class C:
            def optional(self,path):return None
            def request(self,method,path,**kw):
                if method=='POST':return {'data':{'id':'img','attributes':{'uploadOperations':[{'offset':0,'length':length,'url':'https://upload.example.test/asset','method':'PUT','requestHeaders':[{'name':'Content-Type','value':'image/png'}]}]}}}
                if method=='PATCH':return {}
                return {'data':{'attributes':{'assetDeliveryState':{'state':'COMPLETE'}}}}
        s=gc.Sync(C(),True)
        import requests
        with patch.object(requests,'request') as upload:
            upload.return_value.ok=True;s.artwork('gameCenterAchievement','locale',p)
            self.assertNotIn('Authorization',upload.call_args.kwargs['headers']);self.assertEqual(upload.call_args.kwargs['data'],p.read_bytes())
        self.assertEqual(s.ready,1)
if __name__=='__main__':unittest.main()
