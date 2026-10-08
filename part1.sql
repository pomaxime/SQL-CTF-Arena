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

USE ctfarena;

-- Mission 1.4 — 

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'admin_ctf'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'orga_ctf'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'app_web'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'auditeur'@'localhost';

CREATE ROLE role_admin;
CREATE ROLE role_orga;
CREATE ROLE role_app;
CREATE ROLE role_audit;

GRANT ALL PRIVILEGES
ON ctfarena.*
TO role_admin;

GRANT SELECT, INSERT, UPDATE
ON ctfarena.challenges
TO role_orga;

GRANT SELECT, INSERT, UPDATE
ON ctfarena.categories
TO role_orga;

GRANT SELECT
ON ctfarena.equipes
TO role_orga;

GRANT SELECT
ON ctfarena.equipes
TO role_app;

GRANT SELECT
ON ctfarena.categories
TO role_app;

GRANT SELECT
ON ctfarena.validations
TO role_app;

GRANT INSERT
ON ctfarena.soumissions
TO role_app;

GRANT SELECT
(
    id_joueur,
    pseudo,
    id_equipe,
    role_plateforme
)
ON ctfarena.joueurs
TO role_app;

SET @colonnes_challenges = (
    SELECT GROUP_CONCAT(
        CONCAT('`', REPLACE(COLUMN_NAME, '`', '``'), '`')
        ORDER BY ORDINAL_POSITION
        SEPARATOR ', '
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'ctfarena'
      AND TABLE_NAME = 'challenges'
      AND COLUMN_NAME <> 'flag'
);

SET @sql_grant = CONCAT(
    'GRANT SELECT (',
    @colonnes_challenges,
    ') ON ctfarena.challenges TO role_app'
);

PREPARE stmt FROM @sql_grant;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

GRANT SELECT
ON ctfarena.soumissions
TO role_audit;

GRANT SELECT
ON ctfarena.validations
TO role_audit;

GRANT role_admin
TO 'admin_ctf'@'localhost';

GRANT role_orga
TO 'orga_ctf'@'localhost';

GRANT role_app
TO 'app_web'@'localhost';

GRANT role_audit
TO 'auditeur'@'localhost';

SET DEFAULT ROLE ALL
TO 'admin_ctf'@'localhost';

SET DEFAULT ROLE ALL
TO 'orga_ctf'@'localhost';

SET DEFAULT ROLE ALL
TO 'app_web'@'localhost';

SET DEFAULT ROLE ALL
TO 'auditeur'@'localhost';

SHOW GRANTS FOR 'admin_ctf'@'localhost';

SHOW GRANTS FOR 'orga_ctf'@'localhost';

SHOW GRANTS FOR 'app_web'@'localhost';

SHOW GRANTS FOR 'auditeur'@'localhost';

SHOW GRANTS FOR role_admin;

SHOW GRANTS FOR role_orga;

SHOW GRANTS FOR role_app;

SHOW GRANTS FOR role_audit;