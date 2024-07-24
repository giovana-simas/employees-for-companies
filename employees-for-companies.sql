-- Criação das Tabelas
CREATE TABLE departamentos (
  id_departamento NUMBER PRIMARY KEY,
  nome VARCHAR2(100)
);

CREATE TABLE funcionarios (
  id_funcionario NUMBER PRIMARY KEY,
  nome VARCHAR2(100),
  sobrenome VARCHAR2(100),
  email VARCHAR2(100) UNIQUE,
  telefone VARCHAR2(15),
  data_contratacao DATE,
  salario NUMBER,
  id_departamento NUMBER,
  status VARCHAR2(10),
  FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
);

CREATE TABLE desempenho (
  id_desempenho NUMBER PRIMARY KEY,
  id_funcionario NUMBER,
  data_avaliacao DATE,
  nota NUMBER,
  comentarios VARCHAR2(500),
  FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

-- Criação das Sequences
CREATE SEQUENCE seq_departamentos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_funcionarios START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_desempenho START WITH 1 INCREMENT BY 1;

-- Criação dos Triggers
CREATE OR REPLACE TRIGGER trg_funcionarios_status
BEFORE INSERT OR UPDATE ON funcionarios
FOR EACH ROW
BEGIN
  IF :NEW.status IS NULL THEN
    :NEW.status := 'Ativo';
  END IF;
END;
/

-- Criação das Procedures
CREATE OR REPLACE PROCEDURE adiciona_departamento(
  p_nome IN VARCHAR2
) AS
BEGIN
  INSERT INTO departamentos (id_departamento, nome)
  VALUES (seq_departamentos.NEXTVAL, p_nome);
END;
/

CREATE OR REPLACE PROCEDURE adiciona_funcionario(
  p_nome IN VARCHAR2,
  p_sobrenome IN VARCHAR2,
  p_email IN VARCHAR2,
  p_telefone IN VARCHAR2,
  p_data_contratacao IN DATE,
  p_salario IN NUMBER,
  p_id_departamento IN NUMBER
) AS
BEGIN
  INSERT INTO funcionarios (id_funcionario, nome, sobrenome, email, telefone, data_contratacao, salario, id_departamento, status)
  VALUES (seq_funcionarios.NEXTVAL, p_nome, p_sobrenome, p_email, p_telefone, p_data_contratacao, p_salario, p_id_departamento, 'Ativo');
END;
/

CREATE OR REPLACE PROCEDURE atualiza_funcionario(
  p_id_funcionario IN NUMBER,
  p_nome IN VARCHAR2,
  p_sobrenome IN VARCHAR2,
  p_email IN VARCHAR2,
  p_telefone IN VARCHAR2,
  p_salario IN NUMBER,
  p_id_departamento IN NUMBER
) AS
BEGIN
  UPDATE funcionarios
  SET nome = p_nome,
      sobrenome = p_sobrenome,
      email = p_email,
      telefone = p_telefone,
      salario = p_salario,
      id_departamento = p_id_departamento
  WHERE id_funcionario = p_id_funcionario;
END;
/

CREATE OR REPLACE PROCEDURE inativa_funcionario(
  p_id_funcionario IN NUMBER
) AS
BEGIN
  UPDATE funcionarios
  SET status = 'Inativo'
  WHERE id_funcionario = p_id_funcionario;
END;
/

CREATE OR REPLACE PROCEDURE avalia_desempenho(
  p_id_funcionario IN NUMBER,
  p_data_avaliacao IN DATE,
  p_nota IN NUMBER,
  p_comentarios IN VARCHAR2
) AS
BEGIN
  INSERT INTO desempenho (id_desempenho, id_funcionario, data_avaliacao, nota, comentarios)
  VALUES (seq_desempenho.NEXTVAL, p_id_funcionario, p_data_avaliacao, p_nota, p_comentarios);
END;
/

-- Criação das Funções
CREATE OR REPLACE FUNCTION calcula_media_desempenho(
  p_id_funcionario IN NUMBER
) RETURN NUMBER AS
  v_media NUMBER;
BEGIN
  SELECT AVG(nota)
  INTO v_media
  FROM desempenho
  WHERE id_funcionario = p_id_funcionario;
  
  RETURN v_media;
END;
/

-- Criação das Views
CREATE OR REPLACE VIEW vw_funcionarios_ativos AS
SELECT * FROM funcionarios
WHERE status = 'Ativo';

CREATE OR REPLACE VIEW vw_desempenho_funcionarios AS
SELECT f.nome, f.sobrenome, d.data_avaliacao, d.nota, d.comentarios
FROM funcionarios f
JOIN desempenho d ON f.id_funcionario = d.id_funcionario;
