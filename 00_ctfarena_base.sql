-- =====================================================================
--  PROJET SQL AVANCÉ — « CTF Arena »
--  Script de base : crée la base ctfarena et ses données de départ.
--  Compatible MySQL 8+ / MariaDB 10.6+  —  rejouable (DROP IF EXISTS)
--
--  Situation de départ (volontairement mauvaise) :
--    - seul root accède à la base (les comptes du projet sont supprimés) ;
--    - aucune vue, aucun index secondaire sur la table volumineuse ;
--    - aucune règle automatisée, aucun audit.
-- =====================================================================

-- Remise à zéro complète : DROP DATABASE ne supprime ni les comptes, ni les
-- rôles, ni leurs droits. Sans ce bloc, les droits d'un passage précédent
-- restent actifs et peuvent masquer une erreur dans le script d'un élève.
DROP USER IF EXISTS 'admin_ctf'@'localhost', 'orga_ctf'@'localhost',
                    'app_web'@'localhost',   'auditeur'@'localhost';
DROP ROLE IF EXISTS role_admin, role_orga, role_app, role_audit;

DROP DATABASE IF EXISTS ctfarena;
CREATE DATABASE ctfarena CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ctfarena;

-- ---------------------------------------------------------------------
-- Équipes inscrites au CTF
-- ---------------------------------------------------------------------
CREATE TABLE equipes (
  id_equipe        INT AUTO_INCREMENT PRIMARY KEY,
  nom              VARCHAR(60)  NOT NULL UNIQUE,
  ecole            VARCHAR(60)  NOT NULL,
  bannie           BOOLEAN      NOT NULL DEFAULT FALSE,
  date_inscription DATE         NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Joueurs  (colonnes SENSIBLES : email, mot_de_passe_hash, derniere_ip)
-- ---------------------------------------------------------------------
CREATE TABLE joueurs (
  id_joueur         INT AUTO_INCREMENT PRIMARY KEY,
  pseudo            VARCHAR(40)  NOT NULL UNIQUE,
  email             VARCHAR(120) NOT NULL,
  mot_de_passe_hash CHAR(64)     NOT NULL,
  derniere_ip       VARCHAR(45)  NULL,
  id_equipe         INT          NULL,
  role_plateforme   ENUM('joueur','capitaine','orga') NOT NULL DEFAULT 'joueur',
  CONSTRAINT fk_joueur_equipe FOREIGN KEY (id_equipe) REFERENCES equipes(id_equipe)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Catégories de challenges
-- ---------------------------------------------------------------------
CREATE TABLE categories (
  id_categorie INT AUTO_INCREMENT PRIMARY KEY,
  nom          VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Challenges  (colonne SENSIBLE : flag — ne doit JAMAIS fuiter)
-- ---------------------------------------------------------------------
CREATE TABLE challenges (
  id_challenge INT AUTO_INCREMENT PRIMARY KEY,
  titre        VARCHAR(80)  NOT NULL,
  id_categorie INT          NOT NULL,
  difficulte   ENUM('facile','moyen','difficile') NOT NULL,
  points       INT          NOT NULL,
  flag         VARCHAR(100) NOT NULL,
  statut       ENUM('brouillon','ouvert','ferme') NOT NULL DEFAULT 'brouillon',
  id_auteur    INT          NOT NULL,
  CONSTRAINT fk_chall_cat    FOREIGN KEY (id_categorie) REFERENCES categories(id_categorie),
  CONSTRAINT fk_chall_auteur FOREIGN KEY (id_auteur)    REFERENCES joueurs(id_joueur)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Soumissions de flags  (≈ 60 000 lignes)
-- Volontairement SANS clé étrangère ni index secondaire :
-- en InnoDB une FOREIGN KEY crée un index automatiquement, ce qui
-- fausserait la partie « index » du projet.
-- ---------------------------------------------------------------------
CREATE TABLE soumissions (
  id_soumission   INT AUTO_INCREMENT PRIMARY KEY,
  id_joueur       INT          NOT NULL,
  id_challenge    INT          NOT NULL,
  flag_propose    VARCHAR(100) NOT NULL,
  correct         BOOLEAN      NOT NULL,
  ip_source       VARCHAR(45)  NOT NULL,
  date_soumission DATETIME     NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Validations : une ligne par (équipe, challenge) résolu
-- ---------------------------------------------------------------------
CREATE TABLE validations (
  id_equipe       INT      NOT NULL,
  id_challenge    INT      NOT NULL,
  id_joueur       INT      NOT NULL,
  date_validation DATETIME NOT NULL,
  PRIMARY KEY (id_equipe, id_challenge),
  CONSTRAINT fk_val_equipe FOREIGN KEY (id_equipe)    REFERENCES equipes(id_equipe),
  CONSTRAINT fk_val_chall  FOREIGN KEY (id_challenge) REFERENCES challenges(id_challenge),
  CONSTRAINT fk_val_joueur FOREIGN KEY (id_joueur)    REFERENCES joueurs(id_joueur)
) ENGINE=InnoDB;

-- =====================================================================
--  DONNÉES
-- =====================================================================

INSERT INTO equipes (nom, ecole, bannie, date_inscription) VALUES
 ('Orga',            'Ynov Nantes',   FALSE, '2026-08-20'),
 ('NullPointers',    'Ynov Nantes',   FALSE, '2026-08-25'),
 ('RootMeIfYouCan',  'Ynov Bordeaux', FALSE, '2026-08-26'),
 ('Shellshock',      'Ynov Lyon',     FALSE, '2026-08-27'),
 ('BufferBoys',      'Ynov Paris',    FALSE, '2026-08-28'),
 ('XSSential',       'Ynov Nantes',   FALSE, '2026-08-28'),
 ('Cr4ckH34ds',      'Ynov Toulouse', TRUE,  '2026-08-29'),  -- équipe bannie (triche)
 ('PacketSniffers',  'Ynov Aix',      FALSE, '2026-08-30');

-- 30 joueurs : 1 à 3 = organisateurs (équipe 1), puis 4 joueurs par équipe 2..7
-- et 3 pour PacketSniffers (équipe 8), avec 1 capitaine par équipe
INSERT INTO joueurs (pseudo, email, mot_de_passe_hash, derniere_ip, id_equipe, role_plateforme) VALUES
 ('m0rph3us',   'morpheus@ctfarena.local', SHA2('Orga#1',256),  '10.0.0.10',    1, 'orga'),
 ('tr1n1ty',    'trinity@ctfarena.local',  SHA2('Orga#2',256),  '10.0.0.11',    1, 'orga'),
 ('0racle',     'oracle@ctfarena.local',   SHA2('Orga#3',256),  '10.0.0.12',    1, 'orga');

INSERT INTO joueurs (pseudo, email, mot_de_passe_hash, derniere_ip, id_equipe, role_plateforme)
SELECT CONCAT('player', LPAD(n, 2, '0')),
       CONCAT('player', LPAD(n, 2, '0'), '@mail.example'),
       SHA2(CONCAT('Pwd!', n), 256),
       CONCAT('192.168.', 2 + (n - 1) DIV 4, '.', 10 + n),
       2 + (n - 1) DIV 4,
       IF((n - 1) % 4 = 0, 'capitaine', 'joueur')
FROM (SELECT a.d + b.d * 10 + 1 AS n
      FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
            UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
      CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2) b) t
WHERE n <= 27
ORDER BY n;
-- remarque : le joueur id 4 (player01) est capitaine de NullPointers (équipe 2)

INSERT INTO categories (nom) VALUES
 ('Web'), ('Pwn'), ('Reverse'), ('Crypto'), ('Forensic'), ('OSINT');

INSERT INTO challenges (titre, id_categorie, difficulte, points, flag, statut, id_auteur) VALUES
 ('Cookie Monster',        1, 'facile',    100, 'YNOV{c00k13s_4r3_n0t_s3cur3}',   'ouvert',    1),
 ('Injection Royale',      1, 'moyen',     250, 'YNOV{un10n_s3l3ct_4ll}',          'ouvert',    1),
 ('JWT None',              1, 'difficile', 400, 'YNOV{alg_n0n3_1s_d4ng3r0us}',     'ouvert',    2),
 ('Stack Smash 101',       2, 'facile',    150, 'YNOV{r3t_t0_w1n}',                'ouvert',    2),
 ('Format Fiesta',         2, 'moyen',     300, 'YNOV{%n_wr1t3s_m3m0ry}',          'ouvert',    2),
 ('Heap Of Trouble',       2, 'difficile', 500, 'YNOV{tc4ch3_p01s0n1ng}',          'ouvert',    3),
 ('Crackme Classic',       3, 'facile',    100, 'YNOV{str1ngs_1s_y0ur_fr13nd}',    'ouvert',    3),
 ('Obfuscated Rust',       3, 'difficile', 450, 'YNOV{rust_r3v_1s_p41n}',          'ouvert',    3),
 ('Caesar Salad',          4, 'facile',     50, 'YNOV{r0t13_1s_n0t_crypt0}',       'ouvert',    1),
 ('RSA Small e',           4, 'moyen',     300, 'YNOV{cub3_r00t_4tt4ck}',          'ouvert',    1),
 ('Padding Oracle',        4, 'difficile', 450, 'YNOV{cbc_p4dd1ng_0r4cl3}',        'ouvert',    2),
 ('Memory Dump',           5, 'moyen',     250, 'YNOV{v0l4t1l1ty_m4st3r}',         'ouvert',    3),
 ('PCAP Hunt',             5, 'facile',    100, 'YNOV{f0ll0w_tcp_str34m}',         'ouvert',    3),
 ('Where Is Bob',          6, 'facile',    100, 'YNOV{g30l0c4t3d}',                'ouvert',    1),
 ('Exif Secrets',          6, 'moyen',     200, 'YNOV{m3t4d4t4_l34ks}',            'ouvert',    2),
 ('Kernel Panic',          2, 'difficile', 600, 'YNOV{r1ng0_pwn3d}',               'brouillon', 2),
 ('Quantum Crypto',        4, 'difficile', 500, 'YNOV{p0st_qu4ntum_l0l}',          'brouillon', 1),
 ('SSRF Me',               1, 'moyen',     300, 'YNOV{1nt3rn4l_m3t4d4t4}',         'brouillon', 3),
 ('Legacy Login',          1, 'facile',    100, 'YNOV{0ld_but_g0ld}',              'ferme',     1),
 ('Warmup',                6, 'facile',     10, 'YNOV{w3lc0m3}',                   'ferme',     3);

-- ---------------------------------------------------------------------
-- 60 000 soumissions générées de façon déterministe
-- (table de nombres 0..99999 par produit cartésien : portable MySQL/MariaDB)
-- Les joueurs 4..30 soumettent sur les challenges ouverts (1..15).
-- ---------------------------------------------------------------------
INSERT INTO soumissions (id_joueur, id_challenge, flag_propose, correct, ip_source, date_soumission)
SELECT j, c,
       IF(ok, ch.flag, CONCAT('YNOV{essai_', n % 997, '}')),
       ok,
       CONCAT('192.168.', 2 + (j - 4) DIV 4, '.', 10 + (j - 3)),
       TIMESTAMP('2026-09-01 08:00:00') + INTERVAL ((n * 7919) % 2592000) SECOND
FROM (
  SELECT n,
         4 + (n * 31) % 27      AS j,
         1 + (n * 17) % 15      AS c,
         (n % 23 = 0 AND 1 + (n * 17) % 15 <= 15 - 2 * ((((4 + (n * 31) % 27) - 4) DIV 4) * 3 % 7)) AS ok  -- niveau variable selon l'équipe
  FROM (SELECT a.d + b.d*10 + c.d*100 + e.d*1000 + f.d*10000 AS n
        FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
        CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
        CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e
        CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6) f
       ) nums
  WHERE n < 60000
) g
JOIN challenges ch ON ch.id_challenge = g.c
ORDER BY 6;

-- ---------------------------------------------------------------------
-- Incident (à découvrir en Partie 2) : partage de flags entre équipes.
-- Un joueur de BufferBoys valide, un joueur de Cr4ckH34ds soumet le même
-- flag correct une à deux minutes plus tard — d'où le bannissement.
-- ---------------------------------------------------------------------
INSERT INTO soumissions (id_joueur, id_challenge, flag_propose, correct, ip_source, date_soumission) VALUES
 (17,  3, 'YNOV{alg_n0n3_1s_d4ng3r0us}', TRUE, '192.168.5.24', '2026-09-12 21:14:05'),
 (25,  3, 'YNOV{alg_n0n3_1s_d4ng3r0us}', TRUE, '192.168.7.32', '2026-09-12 21:15:12'),
 (17,  6, 'YNOV{tc4ch3_p01s0n1ng}',      TRUE, '192.168.5.24', '2026-09-13 22:40:51'),
 (26,  6, 'YNOV{tc4ch3_p01s0n1ng}',      TRUE, '192.168.7.33', '2026-09-13 22:42:03'),
 (18, 11, 'YNOV{cbc_p4dd1ng_0r4cl3}',    TRUE, '192.168.5.25', '2026-09-14 23:02:17'),
 (25, 11, 'YNOV{cbc_p4dd1ng_0r4cl3}',    TRUE, '192.168.7.32', '2026-09-14 23:03:40');

-- Les équipes valident un challenge à leur PREMIÈRE soumission correcte
INSERT INTO validations (id_equipe, id_challenge, id_joueur, date_validation)
SELECT x.id_equipe, x.id_challenge, x.id_joueur, x.date_soumission
FROM (
  SELECT j.id_equipe, s.id_challenge, s.id_joueur, s.date_soumission,
         ROW_NUMBER() OVER (PARTITION BY j.id_equipe, s.id_challenge
                            ORDER BY s.date_soumission, s.id_soumission) AS rang
  FROM soumissions s
  JOIN joueurs j ON j.id_joueur = s.id_joueur
  WHERE s.correct = TRUE
) x
WHERE x.rang = 1;

-- ---------------------------------------------------------------------
-- Contrôle rapide
-- ---------------------------------------------------------------------
SELECT 'equipes' AS table_, COUNT(*) AS nb FROM equipes
UNION ALL SELECT 'joueurs',     COUNT(*) FROM joueurs
UNION ALL SELECT 'categories',  COUNT(*) FROM categories
UNION ALL SELECT 'challenges',  COUNT(*) FROM challenges
UNION ALL SELECT 'soumissions', COUNT(*) FROM soumissions
UNION ALL SELECT 'validations', COUNT(*) FROM validations;
