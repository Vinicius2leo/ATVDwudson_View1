
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_atualizacao TIMESTAMP
);


CREATE TABLE IF NOT EXISTS funcionarios (
    id_funcionario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    idade INTEGER,
    cargo VARCHAR(50),
    tipo_contrato VARCHAR(20) DEFAULT 'CLT'
);



DROP TABLE historico_produtos;
DROP TABLE produtos;

CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2),
    estoque INTEGER,
    categoria VARCHAR(50)
);

CREATE TABLE historico_produtos (
    id_historico SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto),
    nome_anterior VARCHAR(100),
    preco_anterior DECIMAL(10,2),
    estoque_anterior INTEGER,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acao VARCHAR(10)
);



CREATE OR REPLACE FUNCTION verificar_idade_funcionario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.idade < 18 THEN
        NEW.tipo_contrato = 'MENOR_APRENDIZ';
    ELSE
        NEW.tipo_contrato = 'CLT';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_verificar_idade_funcionarios
BEFORE INSERT OR UPDATE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION verificar_idade_funcionario();


CREATE OR REPLACE FUNCTION registrar_historico_produto()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO historico_produtos (
            id_produto, nome_anterior, preco_anterior, estoque_anterior, acao
        ) VALUES (
            OLD.id_produto, OLD.nome, OLD.preco, OLD.estoque, 'UPDATE'
        );
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO historico_produtos (
            id_produto, nome_anterior, preco_anterior, estoque_anterior, acao
        ) VALUES (
            OLD.id_produto, OLD.nome, OLD.preco, OLD.estoque, 'DELETE'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_registrar_historico_produtos
AFTER UPDATE OR DELETE ON produtos
FOR EACH ROW
EXECUTE FUNCTION registrar_historico_produto();


INSERT INTO usuarios (nome, email, telefone) VALUES
('João Silva', 'joao@email.com', '(11) 99999-8888'),
('Maria Santos', 'maria@email.com', '(21) 98888-7777');

INSERT INTO funcionarios (nome, cpf, idade, cargo) VALUES
('Carlos Oliveira', '123.456.789-00', 25, 'Analista'),
('Ana Pereira', '987.654.321-00', 16, 'Auxiliar'),
('Pedro Costa', '456.123.789-00', 30, 'Gerente');

SELECT * FROM usuarios;

INSERT INTO funcionarios (nome, cpf, idade, cargo) 
VALUES ('Lucas Souza', '111.222.333-44', 17, 'Estagiário');

SELECT * FROM funcionarios;


SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers 
WHERE trigger_schema = 'public';