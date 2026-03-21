using './main.bicep'

param env = 'dev'
param location = 'westeurope'
param sshKeyData = readEnvironmentVariable('SSH_KEY_DATA')
