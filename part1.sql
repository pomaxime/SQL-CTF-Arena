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

-- Mission 1.3

-- voir tableau Compte rendu

-- Mission 1.4



-- Mission 1.5

-- 1.
REVOKE SELECT
ON ctfarena.soumissions
FROM 'auditeur'@'localhost';

GRANT SELECT (
    id_soumission,
    id_joueur,
    id_challenge,
    date_soumission
)
ON ctfarena.soumissions
TO 'auditeur'@'localhost';

-- 2.
-- Test refusé
-- Prédiction : erreur 1143
SELECT ip_source
FROM ctfarena.soumissions;

-- Test accepté
SELECT
    id_soumission,
    id_joueur,
    id_challenge,
    date_soumission
FROM ctfarena.soumissions;


-- Mission 1.6

-- 1.
ALTER USER 'orga_ctf'@'localhost'
ACCOUNT LOCK;


-- 2.
mysql -u orga_ctf -p ctfarena
Résultat attendu :
ERROR 4151 : Access denied, this account is locked


-- 3.
ALTER USER 'orga_ctf'@'localhost'
IDENTIFIED BY 'N0uveau!Mdp';

ALTER USER 'orga_ctf'@'localhost'
ACCOUNT UNLOCK;


-- 4.
ALTER USER 'app_web'@'localhost'
WITH MAX_USER_CONNECTIONS 20;

ALTER USER 'orga_ctf'@'localhost'
PASSWORD EXPIRE INTERVAL 90 DAY;

ALTER USER 'auditeur'@'localhost'
PASSWORD EXPIRE INTERVAL 90 DAY;

SHOW CREATE USER 'orga_ctf'@'localhost';
SHOW CREATE USER 'app_web'@'localhost';
SHOW CREATE USER 'auditeur'@'localhost';