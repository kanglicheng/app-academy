DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY ( author_id ) REFERENCES users(id)

);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
  FOREIGN KEY (author_id) REFERENCES users(id)
);



DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);



  INSERT INTO
  users (fname, lname)
  VALUES
  ('andrew', 'james');
  INSERT INTO
  users (fname, lname)
  VALUES
  ('ben', 'franklin');
  INSERT INTO
  users (fname, lname)
  VALUES
  ('julie', 'andrew');

INSERT INTO questions(title, body, author_id)
VALUES( 'where are you', 'hi im looking for blah', 1);

INSERT INTO
questions(title, body, author_id)
VALUES('question2', 'new_body2', 2);

INSERT INTO question_follows(user_id, question_id)
VALUES(2, 1);

INSERT INTO question_follows(user_id, question_id)
VALUES(2, 2);

INSERT INTO question_follows(user_id, question_id)
VALUES(3, 2);

INSERT INTO question_follows(user_id, question_id)
VALUES(3, 1);

INSERT INTO replies(question_id, author_id, body)
VALUES(1, 3, 'Im over here');

INSERT INTO replies(question_id, parent_reply_id, author_id, body)
VALUES(1, 1, 2, 'OK');
