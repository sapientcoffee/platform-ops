import os

os.system('rm diff.txt')
os.system('ls -lrt')
os.system('git diff HEAD^ HEAD /workspace/repo > diff.txt')
os.system('cat diff.txt')