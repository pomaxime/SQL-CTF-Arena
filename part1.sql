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

SET DEFAULT ROLE ALL        -- A VERIFIER
TO 'admin_ctf'@'localhost'; -- A VERIFIER

SET DEFAULT ROLE ALL        -- A VERIFIER
TO 'orga_ctf'@'localhost';  -- A VERIFIER

SET DEFAULT ROLE ALL        -- A VERIFIER
TO 'app_web'@'localhost';   -- A VERIFIER

SET DEFAULT ROLE ALL        -- A VERIFIER
TO 'auditeur'@'localhost';  -- A VERIFIER

SHOW GRANTS FOR 'admin_ctf'@'localhost';
SHOW GRANTS FOR 'orga_ctf'@'localhost';
SHOW GRANTS FOR 'app_web'@'localhost';
SHOW GRANTS FOR 'auditeur'@'localhost';
SHOW GRANTS FOR role_admin;
SHOW GRANTS FOR role_orga;
SHOW GRANTS FOR role_app;
SHOW GRANTS FOR role_audit;



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