PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS question_likes; 
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    users_id INTEGER NOT NULL,

    FOREIGN KEY (users_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
    id INTEGER PRIMARY KEY,
    questions_id INTEGER NOT NULL, 
    users_id INTEGER NOT NULL,

    FOREIGN KEY (questions_id) REFERENCES questions(id),
    FOREIGN KEY (users_id) REFERENCES users(id)
);

CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    questions_id INTEGER NOT NULL, 
    users_id INTEGER NOT NULL,
    parent_id INTEGER,


    FOREIGN KEY (questions_id) REFERENCES questions(id),
    FOREIGN KEY (users_id) REFERENCES users(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    questions_id INTEGER NOT NULL, 
    users_id INTEGER NOT NULL,

    FOREIGN KEY (users_id) REFERENCES users(id), 
    FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO 
    users (fname, lname)
VALUES 
    ('Lily', 'Lu'),
    ('Tony', 'Baloney'),
    ('Lawrence', 'Nguyen'),
    ('David', 'Elrod'),
    ('Michael', 'Chen');

INSERT INTO 
    questions (title, body, users_id)
VALUES 
    ('Project 09', 'For the in class project 09, does anyone know what is a “service”? And what is a pos in ROUTES table? The questions are not hard but very confusing  0. 0', (SELECT id FROM users WHERE fname = 'Lily' AND lname = 'Lu')),
    ('SQL Bolt', 'anyone else having an issue with the SQL Bolt?', (SELECT id FROM users WHERE fname = 'Tony' AND lname = 'Baloney')),
    ('Simon HW', 'anyone have any idea why my gets.chomp on the simon homework won''t take my input after I hit enter?', (SELECT id FROM users WHERE fname = 'Tony' AND lname = 'Baloney'));

INSERT INTO
    replies (users_id, body, questions_id, parent_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Lawrence' AND lname = 'Nguyen'), 'I think you could consider a service as a route. And each pos would be which number stop it is along that route.', 1, NULL ), -- TODO fix if broken
    ((SELECT id FROM users WHERE fname = 'David' AND lname = 'Elrod'), 'did you split it? I think it wants an array', 3, NULL ),
    ((SELECT id FROM users WHERE fname = 'David' AND lname = 'Elrod'), '(mine is stuck in a weird infinite loop, so what do I know?', 3, 2);

INSERT INTO
    question_likes (users_id, questions_id)
VALUES
    (5, 2),
    (2, 3);

INSERT INTO
    question_follows (questions_id, users_id)
VALUES
    (2, 4),
    (1, 5);