-- Mission 1.1
DROP USER IF EXISTS 'admin_ctf'@'localhost';
DROP USER IF EXISTS 'orga_ctf'@'localhost';
DROP USER IF EXISTS 'app_web'@'localhost';
DROP USER IF EXISTS 'auditeur'@'localhost';

CREATE USER IF NOT EXISTS 'admin_ctf'@'localhost' IDENTIFIED BY 'Admin_26';
CREATE USER IF NOT EXISTS 'orga_ctf'@'localhost' IDENTIFIED BY 'Orga_26';
CREATE USER IF NOT EXISTS 'app_web'@'localhost' IDENTIFIED BY 'App_26';
CREATE USER IF NOT EXISTS 'auditeur'@'localhost' IDENTIFIED BY 'Auditeur_26';

-- Question :
-- Pourquoi ne faut-il pas créer app_web avec @'%' ?
-- Réponse : @'%' autoriserait la connexion depuis n'importe quelle adresse IP. 
-- Cela augmente inutilement la surface d'attaque. @'localhost' limite
-- la connexion au serveur local.

-- Mission 1.2

GRANT ALL PRIVILEGES ON ctfarena.*
TO 'admin_ctf'@'localhost';

GRANT SELECT, INSERT, UPDATE
ON ctfarena.challenges
TO 'orga_ctf'@'localhost';

GRANT SELECT, INSERT, UPDATE
ON ctfarena.categories
TO 'orga_ctf'@'localhost';

GRANT SELECT
ON ctfarena.equipes
TO 'orga_ctf'@'localhost';

-- equipes, categories, validations : SELECT
GRANT SELECT
ON ctfarena.equipes
TO 'app_web'@'localhost';

GRANT SELECT
ON ctfarena.categories
TO 'app_web'@'localhost';

GRANT SELECT
ON ctfarena.validations
TO 'app_web'@'localhost';

-- soumissions : INSERT
GRANT INSERT
ON ctfarena.soumissions
TO 'app_web'@'localhost';

-- joueurs : SELECT uniquement sur certaines colonnes
GRANT SELECT (id_joueur, pseudo, id_equipe, role_plateforme)
ON ctfarena.joueurs
TO 'app_web'@'localhost';

-- challenges : SELECT sur toutes les colonnes SAUF flag
GRANT SELECT (
    id_challenge,
    nom,
    description,
    points,
    id_categorie,
    statut
)
ON ctfarena.challenges
TO 'app_web'@'localhost';

GRANT SELECT
ON ctfarena.soumissions
TO 'auditeur'@'localhost';

GRANT SELECT
ON ctfarena.validations
TO 'auditeur'@'localhost';

SHOW GRANTS FOR 'admin_ctf'@'localhost';
SHOW GRANTS FOR 'orga_ctf'@'localhost';
SHOW GRANTS FOR 'app_web'@'localhost';
SHOW GRANTS FOR 'auditeur'@'localhost';