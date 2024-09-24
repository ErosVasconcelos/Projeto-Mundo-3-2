CREATE LOGIN loja WITH PASSWORD = 'loja';
CREATE USER loja FOR LOGIN loja;
ALTER SERVER ROLE sysadmin ADD MEMBER loja;

CREATE DATABASE SistemaLoja;
USE SistemaLoja;

CREATE TABLE Usuarios (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100),
    Login VARCHAR(50),
    Senha VARCHAR(50)
);

CREATE TABLE Pessoas (
    ID_Pessoa INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100),
    Endereco VARCHAR(100),
    Telefone VARCHAR(15),
    Email VARCHAR(50)
);

CREATE TABLE PessoasFisicas (
    ID_Pessoa INT PRIMARY KEY,
    CPF VARCHAR(11),
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoas(ID_Pessoa)
);

CREATE TABLE PessoasJuridicas (
    ID_Pessoa INT PRIMARY KEY,
    CNPJ VARCHAR(14),
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoas(ID_Pessoa)
);

CREATE TABLE Produtos (
    ID_Produto INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100),
    Quantidade INT,
    PrecoVenda DECIMAL(10, 2)
);


CREATE TABLE MovimentosCompra (
    ID_Compra INT IDENTITY(1,1) PRIMARY KEY,
    ID_Usuario INT,
    ID_Produto INT,
    ID_PessoaJuridica INT,
    Quantidade INT,
    PrecoUnitario DECIMAL(10, 2),
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID),
    FOREIGN KEY (ID_Produto) REFERENCES Produtos(ID_Produto),
    FOREIGN KEY (ID_PessoaJuridica) REFERENCES PessoasJuridicas(ID_Pessoa)
);

CREATE TABLE MovimentosVenda (
    ID_Venda INT IDENTITY(1,1) PRIMARY KEY,
    ID_Usuario INT,
    ID_Produto INT,
    ID_PessoaFisica INT,
    Quantidade INT,
    PrecoVenda DECIMAL(10, 2),
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID),
    FOREIGN KEY (ID_Produto) REFERENCES Produtos(ID_Produto),
    FOREIGN KEY (ID_PessoaFisica) REFERENCES PessoasFisicas(ID_Pessoa)
);

CREATE SEQUENCE Seq_Pessoa AS INT START WITH 1 INCREMENT BY 1;

INSERT INTO Usuarios (Nome, Login, Senha) VALUES 
('Operador 1', 'op1', 'op1'),
('Operador 2', 'op2', 'op2');

INSERT INTO Produtos (Nome, Quantidade, PrecoVenda) VALUES 
('Produto A', 100, 10.00),
('Produto B', 200, 15.50),
('Produto C', 150, 7.25);

INSERT INTO Pessoas (Nome, Endereco, Telefone, Email) 
VALUES ('João da Silva', 'Rua A, 123', '123456789', 'joao@example.com');

DECLARE @ID_PessoaFisica INT = SCOPE_IDENTITY();

INSERT INTO PessoasFisicas (ID_Pessoa, CPF) 
VALUES (@ID_PessoaFisica, '12345678901');

INSERT INTO Pessoas (Nome, Endereco, Telefone, Email) 
VALUES ('Empresa XYZ', 'Avenida C, 789', '456789123', 'contato@xyz.com');

DECLARE @ID_PessoaJuridica INT = SCOPE_IDENTITY();

INSERT INTO PessoasJuridicas (ID_Pessoa, CNPJ) 
VALUES (@ID_PessoaJuridica, '12345678000195');


INSERT INTO MovimentosCompra (ID_Usuario, ID_Produto, ID_PessoaJuridica, Quantidade, PrecoUnitario) VALUES 
(11, 16, 26, 10, 10.00),
(11, 17, 26, 5, 15.50); 

INSERT INTO MovimentosVenda (ID_Usuario, ID_Produto, ID_PessoaFisica, Quantidade, PrecoVenda) VALUES 
(11, 16, 25, 2, 10.00),
(11, 17, 25, 1, 15.50);



SELECT * FROM Pessoas;
SELECT * FROM PessoasFisicas;
SELECT * FROM PessoasJuridicas;
SELECT * FROM Produtos;
SELECT * FROM Usuarios;

SELECT P.ID_Pessoa, P.Nome, P.Endereco, P.Telefone, P.Email, PF.CPF
FROM Pessoas P
JOIN PessoasFisicas PF ON P.ID_Pessoa = PF.ID_Pessoa;

SELECT P.ID_Pessoa, P.Nome, P.Endereco, P.Telefone, P.Email, PJ.CNPJ
FROM Pessoas P
JOIN PessoasJuridicas PJ ON P.ID_Pessoa = PJ.ID_Pessoa;

SELECT 
    P.Nome AS Fornecedor,
    Prod.Nome AS Produto,
    MC.Quantidade,
    MC.PrecoUnitario,
    MC.Quantidade * MC.PrecoUnitario AS ValorTotal
FROM MovimentosCompra MC
JOIN Produtos Prod ON MC.ID_Produto = Prod.ID_Produto
JOIN PessoasJuridicas PJ ON MC.ID_PessoaJuridica = PJ.ID_Pessoa
JOIN Pessoas P ON PJ.ID_Pessoa = P.ID_Pessoa;

SELECT 
    P.Nome AS Comprador,
    Prod.Nome AS Produto,
    MV.Quantidade,
    MV.PrecoVenda,
    MV.Quantidade * MV.PrecoVenda AS ValorTotal
FROM MovimentosVenda MV
JOIN Produtos Prod ON MV.ID_Produto = Prod.ID_Produto
JOIN PessoasFisicas PF ON MV.ID_PessoaFisica = PF.ID_Pessoa
JOIN Pessoas P ON PF.ID_Pessoa = P.ID_Pessoa;

SELECT 
    Prod.Nome AS Produto,
    SUM(MC.Quantidade * MC.PrecoUnitario) AS ValorTotalEntradas
FROM MovimentosCompra MC
JOIN Produtos Prod ON MC.ID_Produto = Prod.ID_Produto
GROUP BY Prod.Nome;

SELECT U.*
FROM Usuarios U
WHERE NOT EXISTS (
    SELECT 1
    FROM MovimentosCompra MC
    WHERE MC.ID_Usuario = U.ID
);

SELECT 
    U.Nome AS Operador,
    SUM(MC.Quantidade * MC.PrecoUnitario) AS ValorTotalEntradas
FROM MovimentosCompra MC
JOIN Usuarios U ON MC.ID_Usuario = U.ID
GROUP BY U.Nome;

SELECT 
    U.Nome AS Operador,
    SUM(MV.Quantidade * MV.PrecoVenda) AS ValorTotalSaidas
FROM MovimentosVenda MV
JOIN Usuarios U ON MV.ID_Usuario = U.ID
GROUP BY U.Nome;

SELECT 
    Prod.Nome AS Produto,
    SUM(MV.PrecoVenda * MV.Quantidade) / SUM(MV.Quantidade) AS ValorMedioVenda
FROM MovimentosVenda MV
JOIN Produtos Prod ON MV.ID_Produto = Prod.ID_Produto
GROUP BY Prod.Nome;
