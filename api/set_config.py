import yaml
import sys


f = open('.firesuit/config.yml')
currentConfig = yaml.safe_load(f)
f.close()

config = currentConfig
config[sys.argv[1]] = sys.argv[2]

with open('.firesuit/config.yml', 'w') as outfile:
    outfile.write( yaml.dump(config, default_flow_style=False) )
