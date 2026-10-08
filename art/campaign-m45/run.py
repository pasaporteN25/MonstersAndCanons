"""Corridas headless independientes; no benchmark de FPS. Resultados incrementales."""
from pathlib import Path
import concurrent.futures, subprocess, os, json, sys
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/t192';OUT.mkdir(parents=True,exist_ok=True)
RESULT=ROOT/'art/campaign-m45/results.json'
phase=sys.argv[1] if len(sys.argv)>1 else 'screen'
profiles=['baseline','upgrades','upgrade_support','adaptive_upgrades','adaptive_upgrade_late_value','late_damage']
cases=[(n,p,42,'normal') for n in [8,9] for p in profiles]
if phase=='extra': cases=[(n,p,42,'normal') for n in [8,9] for p in ['late_damage','upgrade_late','upgrade_support']]
if phase=='validate': cases=[(n,p,s,'normal') for n in [8,9] for p in ['baseline','adaptive_upgrades','late_damage'] for s in [7,12345]]
if phase=='pressure': cases=[(n,p,42,q) for n in [8,9] for p in ['upgrades','upgrade_late_value','upgrade_support'] for q in ['none','double']]
if phase=='repeat': cases=[(9,'baseline',42,'normal')]
rows=json.loads(RESULT.read_text(encoding='utf8')) if RESULT.exists() else []
existing={(r['level'],r['profile'],r['seed'],r['pressure']) for r in rows if 'global_seed' in r}
cases=[c for c in cases if c not in existing] if phase!='repeat' else cases
def run(case):
 n,p,s,q=case;tag=f'{n}-{p}-{s}-{q}'
 env=os.environ.copy();env['APPDATA']=str(OUT/('user-'+tag))
 command=['C:/Tools/Godot/godot.cmd','--headless','--path',str(ROOT),'--fixed-fps','60','-s','art/campaign-m45/sim.gd','--','mix',f'level={n}',f'profile={p}',f'seed={s}',f'pressure={q}']
 result=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,timeout=360)
 output=(result.stdout+result.stderr).decode('utf8',errors='replace')
 (OUT/(tag+'.log')).write_text(output,encoding='utf8')
 if result.returncode or 'SCRIPT ERROR' in output or 'Parse Error' in output: raise RuntimeError(tag+' revisar log')
 line=next(x for x in output.splitlines() if x.startswith('M44_RESULT '))
 return json.loads(line.removeprefix('M44_RESULT '))
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 for result in pool.map(run,cases):
  if phase=='repeat':
   previous=next(r for r in rows if r['level']==9 and r['profile']=='baseline' and r['seed']==42 and r['pressure']=='normal')
   assert result==previous, 'La repetición difiere del control: revisar antes de concluir'
   (RESULT.parent/'repeat.json').write_text(json.dumps({'identical':True,'result':result},indent=2)+'\n',encoding='utf8')
   print('Repetición idéntica al control',flush=True)
   continue
  rows.append(result);RESULT.write_text(json.dumps(rows,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
  print(f"{result['level']} {result['profile']} seed={result['seed']} {result['pressure']} win={result['won']} lives={result['lives']} upgrades={result['upgrades']} stolen={result['stolen']} impacts={result['impacts']} support={[x for x in result['purchases'] if x['kind']=='support']}",flush=True)
