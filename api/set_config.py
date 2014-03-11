import yaml
import sys

filePath = os.path.dirname(os.path.realpath(__file__))+'/.firesuit/config.yml'

f = open(filePath)
currentConfig = yaml.safe_load(f)
f.close()

config = currentConfig
config[sys.argv[1]] = sys.argv[2]

with open(filePath, 'w') as outfile:
    outfile.write( yaml.dump(config, default_flow_style=False) )
