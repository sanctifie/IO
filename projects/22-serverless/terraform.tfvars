# Aucun secret ici : le mot de passe d'Aurora est généré et stocké par RDS dans Secrets Manager.
region          = "eu-west-3"
name            = "dev"
cidr_block      = "10.20.0.0/16"
private_subnets = 2
api_stage       = "v1"
domain          = "" # ex. "api.mondomaine.fr" si tu as une zone Route 53 + un certificat ACM
