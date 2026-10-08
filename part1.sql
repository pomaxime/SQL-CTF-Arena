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

