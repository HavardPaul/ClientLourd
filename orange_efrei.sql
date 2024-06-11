-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 30 mai 2024 à 14:30
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `orange_efrei`
--
DROP DATABASE IF EXISTS orange_efrei;
CREATE DATABASE orange_efrei;
USE orange_efrei;

DELIMITER $$
--
-- Procédures
--

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteClient` (IN `p_idclient` INT)   Begin
	delete from produit where idclient=p_idclient;
	delete from client where idclient=p_idclient;
End$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertClient` (IN `p_nom` VARCHAR(50), IN `p_prenom` VARCHAR(50), IN `p_adresse` VARCHAR(50), IN `p_email` VARCHAR(50))   Begin
	#Vérifier avant insertion que l'email renseigner n'existe pas déjà dans la base de données
	declare nb int;
	SELECT COUNT(*) INTO NB from client where email=p_email;
	if nb = 0 then 
	insert client values (null, p_nom, p_prenom, p_adresse, p_email, null);
	end if;
End$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertProduit` (IN `p_designation` VARCHAR(50), IN `p_prixAchat` FLOAT, IN `p_dateAchat` DATE, IN `p_categorie` VARCHAR(50), IN `p_idclient` INT(3))   Begin
	#Si prixAchat<0 alors =0
	if p_prixAchat <0 then set p_prixAchat=0;
	end if;
	#Si la date est null, mettre la date d'aujourd'hui
	if p_dateAchat = "" or p_dateAchat is null then
	set p_dateAchat = sysdate();
	end if;
	#Par défaut, la catégorie sera télévision
	if p_categorie = "" or p_categorie is null then
	set p_categorie = "Télévision";
	end if;
	#Insertion du produit
	insert produit values (null, p_designation, p_prixAchat, p_dateAchat, p_categorie, p_idclient);
End$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE `client` (
  `idclient` int(3) NOT NULL,
  `nom` varchar(50) DEFAULT NULL,
  `prenom` varchar(50) DEFAULT NULL,
  `adresse` varchar(100) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `compte` int(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`idclient`, `nom`, `prenom`, `adresse`, `email`, `compte`) VALUES
(1, 'Havard', 'Paule', '85 Avenue de la République', 'z@gmail.com', NULL),
(4, 'Havard', 'Paul', '76 Avenue Pierre Mendès France', 'x@gmail.com', NULL),
(24, 'Ripoll', 'Thomas', '59 Rue de la Vodka', 'ripoll@gmail.com', 10);

--
-- Déclencheurs `client`
--
DELIMITER $$
CREATE TRIGGER `attrib_compte` BEFORE INSERT ON `client` FOR EACH ROW BEGIN 
    DECLARE user_id INT;
    DECLARE user_role VARCHAR(255);
    
    SELECT iduser INTO user_id FROM user WHERE email = NEW.email LIMIT 1;
    SELECT role INTO user_role FROM user WHERE email = NEW.email LIMIT 1;
    
    IF user_id IS NOT NULL AND user_role="client" THEN
        SET NEW.compte = user_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `intervention`
--

CREATE TABLE `intervention` (
  `idinter` int(3) NOT NULL,
  `description` text DEFAULT NULL,
  `prixInter` float DEFAULT NULL,
  `dateInter` date DEFAULT NULL,
  `idproduit` int(3) NOT NULL,
  `idtechnicien` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `intervention`
--

INSERT INTO `intervention` (`idinter`, `description`, `prixInter`, `dateInter`, `idproduit`, `idtechnicien`) VALUES
(1, 'Remplacement de la batterie', 50.5, '2024-02-06', 1, 3),
(3, 'Réparation de l écran', 48.56, '2022-01-07', 1, 1),
(15, 'abc', 50, '2024-05-01', 1, 1),
(18, 'dfzq', 50, '2024-05-02', 2, 1),
(19, 'fefs', 50, '2024-05-22', 1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

CREATE TABLE `produit` (
  `idproduit` int(3) NOT NULL,
  `designation` varchar(50) DEFAULT NULL,
  `prixAchat` float DEFAULT NULL,
  `dateAchat` date DEFAULT NULL,
  `categorie` enum('Téléphone','Informatique','Télévision') DEFAULT NULL,
  `idclient` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`idproduit`, `designation`, `prixAchat`, `dateAchat`, `categorie`, `idclient`) VALUES
(1, 'Iphone', 1260.43, '2024-02-13', 'Téléphone', 1),
(2, 'Téléviseur Sony', 500.99, '2015-11-29', 'Télévision', 1),
(3, 'PC Asus', 989.99, '2022-06-02', 'Informatique', 4),
(37, 'Tablette', 450, '2024-05-01', 'Téléphone', 1);

-- --------------------------------------------------------

--
-- Structure de la table `technicien`
--

CREATE TABLE `technicien` (
  `idtechnicien` int(3) NOT NULL,
  `nom` varchar(50) DEFAULT NULL,
  `prenom` varchar(50) DEFAULT NULL,
  `specialite` varchar(50) DEFAULT NULL,
  `dateEmbauche` date DEFAULT NULL,
  `compte` int(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `technicien`
--

INSERT INTO `technicien` (`idtechnicien`, `nom`, `prenom`, `specialite`, `dateEmbauche`, `compte`) VALUES
(1, 'Leblanc', 'Arthur', 'Téléviseur', '2024-01-05', NULL),
(2, 'Macron', 'Brunos', 'Informatique', '2023-06-25', 4),
(3, 'Lemaire', 'Paul', 'Téléviseur', '2023-05-19', NULL),
(5, 'Othman', 'Rania', 'Eléctronique', '2023-07-06', NULL),
(7, 'Chafik', 'Anasse', 'Cybersécurité', '2024-03-22', 6),
(9, 'Gibert', 'Lucille', 'Développement Web', '2023-02-20', 9),
(10, 'Bracqard', 'Marc', 'Portfolio', '2024-04-01', NULL);

--
-- Déclencheurs `technicien`
--
DELIMITER $$
CREATE TRIGGER `attribution_compte` BEFORE INSERT ON `technicien` FOR EACH ROW BEGIN 
    DECLARE user_id INT;
    DECLARE user_role VARCHAR(255);
    
    SELECT iduser INTO user_id FROM user WHERE nom = NEW.nom LIMIT 1;
    SELECT role INTO user_role FROM user WHERE nom = NEW.nom LIMIT 1;
    
    IF user_id IS NOT NULL AND user_role = 'techni' THEN
        SET NEW.compte = user_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE `user` (
  `iduser` int(3) NOT NULL,
  `nom` varchar(50) DEFAULT NULL,
  `prenom` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `mdp` varchar(200) DEFAULT NULL,
  `role` enum('admin','user','client','techni') DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `user`
--

INSERT INTO `user` (`iduser`, `nom`, `prenom`, `email`, `mdp`, `role`) VALUES
(1, 'Paul', 'Julienn', 'a@gmail.com', '123', 'admin'),
(4, 'Macron', 'Bruno', 'e@gmail.com', '147', 'techni'),
(6, 'Chafik', 'Anasse', 'anasse@gmail.com', '258', 'techni'),
(9, 'Gibert', 'Lucille', 'gibert@bbox.fr', '654', 'techni'),
(10, 'Ripoll', 'Thomas', 'ripoll@gmail.com', '987', 'client'),
(17, 'Othman', 'Rania', 'z@gmail.com', '852', 'user'),
(18, 'Lagrave', 'Léa', 'lea@gmail.com', '963', NULL);

--
-- Déclencheurs `user`
--
DELIMITER $$
CREATE TRIGGER `compte_attribution` BEFORE INSERT ON `user` FOR EACH ROW BEGIN 
    DECLARE client_email VARCHAR(255);
    DECLARE technicien_nom VARCHAR(255);
    
    SELECT email INTO client_email FROM client WHERE email = NEW.email LIMIT 1;
    SELECT nom INTO technicien_nom FROM technicien WHERE nom = NEW.nom LIMIT 1;
    
    IF NEW.role IS NULL THEN 
    	IF client_email IS NOT NULL  AND technicien_nom IS NULL THEN
        	SET NEW.role = 'client';
    	ELSEIF technicien_nom IS NOT NULL AND client_email IS NULL THEN
        	SET NEW.role = 'techni';
    	ELSEIF client_email IS NOT NULL AND technicien_nom IS NOT NULL THEN
        	SET NEW.role = NULL;
    	ELSE
    		SET NEW.role = NULL;
    	END IF;
    END IF;
END
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `client`
--
ALTER TABLE `client`
  ADD PRIMARY KEY (`idclient`),
  ADD KEY `client_ibfk_1` (`compte`);

--
-- Index pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD PRIMARY KEY (`idinter`),
  ADD KEY `intervention_ibfk_1` (`idproduit`),
  ADD KEY `intervention_ibfk_2` (`idtechnicien`);

--
-- Index pour la table `produit`
--
ALTER TABLE `produit`
  ADD PRIMARY KEY (`idproduit`),
  ADD KEY `produit_ibfk_1` (`idclient`);

--
-- Index pour la table `technicien`
--
ALTER TABLE `technicien`
  ADD PRIMARY KEY (`idtechnicien`),
  ADD KEY `technicien_ibfk_1` (`compte`);

--
-- Index pour la table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`iduser`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `client`
--
ALTER TABLE `client`
  MODIFY `idclient` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT pour la table `intervention`
--
ALTER TABLE `intervention`
  MODIFY `idinter` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `produit`
--
ALTER TABLE `produit`
  MODIFY `idproduit` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT pour la table `technicien`
--
ALTER TABLE `technicien`
  MODIFY `idtechnicien` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `user`
--
ALTER TABLE `user`
  MODIFY `iduser` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `client`
--
ALTER TABLE `client`
  ADD CONSTRAINT `client_ibfk_1` FOREIGN KEY (`compte`) REFERENCES `user` (`iduser`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD CONSTRAINT `intervention_ibfk_1` FOREIGN KEY (`idproduit`) REFERENCES `produit` (`idproduit`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `intervention_ibfk_2` FOREIGN KEY (`idtechnicien`) REFERENCES `technicien` (`idtechnicien`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `produit`
--
ALTER TABLE `produit`
  ADD CONSTRAINT `produit_ibfk_1` FOREIGN KEY (`idclient`) REFERENCES `client` (`idclient`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `technicien`
--
ALTER TABLE `technicien`
  ADD CONSTRAINT `technicien_ibfk_1` FOREIGN KEY (`compte`) REFERENCES `user` (`iduser`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
