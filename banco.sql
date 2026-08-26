-- Modelo de dados: Plataforma tipo LinkedIn (PostgreSQL)

-- CREATE DATABASE plataforma_profissional;


-- ENUMS 
CREATE TYPE tipo_localidade AS ENUM ('presencial', 'hibrida', 'remota');
CREATE TYPE tipo_emprego AS ENUM ('tempo_integral', 'meio_periodo', 'autonomo', 'freelance', 'temporario', 'estagio', 'aprendiz', 'trainee', 'terceirizado');
CREATE TYPE tipo_telefone AS ENUM ('residencial', 'comercial', 'celular');
CREATE TYPE tipo_status AS ENUM ('aceita', 'pendente');
CREATE TYPE tipo_publicacao AS ENUM ('texto', 'foto', 'video', 'artigo');
CREATE TYPE tipo_atividade AS ENUM ('reacao', 'comentario', 'compartilhamento', 'salvar');
CREATE TYPE tipo_visibilidade AS ENUM('publica', 'conexoes', 'privada');
-- Tabelas

CREATE TABLE localidade (
  id_localidade SERIAL PRIMARY KEY,
  pais VARCHAR(100),
  cidade VARCHAR(100)
);


CREATE TABLE organizacao (
  id_organizacao SERIAL PRIMARY KEY,
  nome_organizacao VARCHAR(200) NOT NULL,
  setor_organizacao VARCHAR(100),
  descricao TEXT,
  site VARCHAR(255),
  email VARCHAR(150),
  localidade_id INT REFERENCES localidade(id_localidade) ON DELETE SET NULL,
  logo VARCHAR(255),
  capa VARCHAR(255),
  criacao DATE DEFAULT CURRENT_DATE,
  ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE usuario (
  id_usuario SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  sobrenome VARCHAR(100),
  nome_alternativo VARCHAR(100),
  pronomes VARCHAR(50),
  data_nascimento DATE,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  email VARCHAR(150) UNIQUE NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  localidade_id INT REFERENCES localidade(id_localidade) ON DELETE SET NULL
);


CREATE TABLE perfil (
  id_perfil SERIAL PRIMARY KEY,
  usuario_id INT UNIQUE REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  link_perfil VARCHAR(150) UNIQUE,
  foto_perfil VARCHAR(255),
  foto_capa VARCHAR(255),
  titulo VARCHAR(150),
  cargo_atual VARCHAR(150),
  setor VARCHAR(100),
  sobre TEXT,
  criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ultima_atualizacao TIMESTAMP
);


CREATE TABLE contato (
  id_contato SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  email VARCHAR(150),
  telefone VARCHAR(30),
  tipo_telefone tipo_telefone,
  endereco VARCHAR(255),
  site VARCHAR(255),
  ultima_atualizacao TIMESTAMP
);


CREATE TABLE experiencia (
  id_experiencia SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL
);

CREATE TABLE usuario_experiencia (
  id_usuario_experiencia SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  experiencia_id INT REFERENCES experiencia(id_experiencia) ON DELETE CASCADE,
  organizacao_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL, 
  cargo VARCHAR(150),
  tipo_emprego tipo_emprego,
  nome_organizacao VARCHAR(150), -- caso queira armazenar nome livre
  mes_inicio SMALLINT,
  ano_inicio SMALLINT,
  mes_fim SMALLINT,
  ano_fim SMALLINT,
  descricao TEXT
);

CREATE TABLE formacao (
  id_formacao SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL
);

CREATE TABLE formacao_usuario (
  id_formacao_usuario SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  organizacao_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL, 
  formacao_id INT REFERENCES formacao(id_formacao) ON DELETE SET NULL,
  nome_organizacao VARCHAR(200) NOT NULL,
  grau VARCHAR(100),
  area_estudo VARCHAR(150),
  mes_inicio SMALLINT,
  ano_inicio SMALLINT,
  mes_fim SMALLINT,
  ano_fim SMALLINT,
  situacao VARCHAR(50),
  descricao TEXT
);

CREATE TABLE competencia (
  id_competencia SERIAL PRIMARY KEY,
  nome_competencia VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE competencia_usuario (
  id_competencia_usuario SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  competencia_id INT REFERENCES competencia(id_competencia) ON DELETE CASCADE,
  formacao_id INT REFERENCES formacao(id_formacao) ON DELETE SET NULL,     
  organizacao_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL, 
  experiencia_id INT REFERENCES experiencia(id_experiencia) ON DELETE SET NULL, 
  descricao TEXT,
  nome_organizacao VARCHAR(150)
);


CREATE TABLE publicacao (
  id_publicacao SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  organizacao_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  descricao TEXT,
  midia VARCHAR(255),
  data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ultima_atualizacao TIMESTAMP,
  visibilidade tipo_visibilidade, 
  tipo_publicacao tipo_publicacao,
  CHECK (
    (
      usuario_id IS NOT NULL AND organizacao_id IS NULL
    ) OR (
      usuario_id IS NULL AND organizacao_id IS NOT NULL
    )
  )
);


CREATE TABLE vaga (
  id_vaga SERIAL PRIMARY KEY,
  organizacao_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  titulo VARCHAR(200),
  descricao TEXT,
  tipo_contrato tipo_emprego,
  localidade tipo_localidade,
  salario NUMERIC(12,2),
  data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ativo BOOLEAN DEFAULT TRUE,
  CHECK (
    (
      usuario_id IS NOT NULL AND organizacao_id IS NULL
    ) OR (
      usuario_id IS NULL AND organizacao_id IS NOT NULL
    )
  )
);



CREATE TABLE candidatura (
  id_candidatura SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  vaga_id INT REFERENCES vaga(id_vaga) ON DELETE CASCADE,
  data_candidatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (usuario_id, vaga_id)
);


CREATE TABLE atividade (
  id_atividade SERIAL PRIMARY KEY,
  tipo_atividade tipo_atividade NOT NULL
);

CREATE TABLE atividade_publicacao (
  id_atividade_publicacao SERIAL PRIMARY KEY,
  usuario_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  organizacao_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  publicacao_id INT REFERENCES publicacao(id_publicacao) ON DELETE CASCADE,
  atividade_id INT REFERENCES atividade(id_atividade) ON DELETE CASCADE,
  tipo_atividade tipo_atividade,
  descricao TEXT,
  data_atividade TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (
    (
      usuario_id IS NOT NULL AND organizacao_id IS NULL
    ) OR (
      usuario_id IS NULL AND organizacao_id IS NOT NULL
    )
  )
);


CREATE TABLE conexao_seguir (
  id_conexao SERIAL PRIMARY KEY,
  usuario_origem_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  usuario_destino_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  organizacao_origem_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  organizacao_destino_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  status tipo_status DEFAULT 'pendente',
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (
    (usuario_origem_id IS NOT NULL OR organizacao_origem_id IS NOT NULL)
    AND (usuario_destino_id IS NOT NULL OR organizacao_destino_id IS NOT NULL)
  )
);


CREATE TABLE mensagem (
  id_mensagem SERIAL PRIMARY KEY,
  usuario_origem_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  organizacao_origem_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  usuario_destino_id INT REFERENCES usuario(id_usuario) ON DELETE SET NULL,
  organizacao_destino_id INT REFERENCES organizacao(id_organizacao) ON DELETE SET NULL,
  conteudo TEXT NOT NULL,
  data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (
    (usuario_origem_id IS NOT NULL OR organizacao_origem_id IS NOT NULL)
    AND (usuario_destino_id IS NOT NULL OR organizacao_destino_id IS NOT NULL)
  )
);


-- Indices

CREATE INDEX idx_organizacao_nome ON organizacao(nome_organizacao);
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_contato_email ON contato(email);
CREATE INDEX idx_competencia_nome ON competencia(nome_competencia);
CREATE INDEX idx_publicacao_data ON publicacao(data_publicacao DESC);
CREATE INDEX idx_vaga_titulo ON vaga(titulo);
CREATE INDEX idx_mensagem_data ON mensagem(data_envio DESC);
CREATE INDEX idx_publicacao_usuario ON publicacao(usuario_id);
CREATE INDEX idx_publicacao_organizacao ON publicacao(organizacao_id);
CREATE INDEX idx_vaga_organizacao ON vaga(organizacao_id);
CREATE INDEX idx_candidatura_usuario ON candidatura(usuario_id);
CREATE INDEX idx_competencia_usuario ON competencia_usuario(usuario_id);


