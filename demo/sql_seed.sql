CREATE TABLE courses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  instructor_id INTEGER NOT NULL
);

CREATE TABLE instructors (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE students (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE enrollments (
  id INTEGER PRIMARY KEY,
  student_id INTEGER NOT NULL,
  course_id INTEGER NOT NULL
);

CREATE TABLE notebooks (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  student_id INTEGER NOT NULL
);

INSERT INTO
  notebooks (id, name, student_id)
VALUES
  (1, 'mead', 1);

INSERT INTO
  courses (id, name, instructor_id)
VALUES
  (1, 'Ruby', 1), (2, 'JavaScript', 1);

INSERT INTO
  instructors (id, name)
VALUES
  (1, 'The professor');

INSERT INTO
  students (id, name)
VALUES
  (1, 'Carnap'), (2, 'Russel'), (3, 'Soames'),
  (4, 'Kripke'), (5, 'Quine'),  (6, 'Frege');

INSERT INTO
  enrollments (id, student_id, course_id)
VALUES
  (1, 1, 1), (2, 2, 1), (3, 3, 1),
  (4, 4, 2), (5, 5, 2), (6, 6, 2);

CREATE TABLE artists (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE albums (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  artist_id INTEGER NOT NULL
);

CREATE TABLE songs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  album_id INTEGER NOT NULL
);

INSERT INTO
  artists (id, name)
VALUES
  (1, 'Bob Marley'), (2, 'Bob Dylan');

INSERT INTO
  albums (id, name, artist_id)
VALUES
  (1, 'Burnin', 1), (2, 'Catch a fire', 1),
  (3, 'Blonde on Blonde', 2);

INSERT INTO
  songs (id, name, album_id)
VALUES
  (1, 'Burnin and Lootin', 1),
  (2, 'Duppy Conqueror', 1),
  (3, 'Get Up, Stand Up', 1),
  (4, 'Hellelujah Time', 1),
  (5, 'I Shot the Sheriff', 1),
  (6, 'One Foundation', 1),
  (7, 'Pass It On', 1),
  (8, 'Put It On', 1),
  (9, 'Rastaman Chant', 1),
  (10, 'Small Axe', 1),
  (11, '400 Years', 2),
  (12, 'Concrete Jungle', 2),
  (13, 'Kinky Reggae', 2),
  (14, 'Midnight Ravers', 2),
  (15, 'No More Trouble', 2),
  (16, 'Slave Driver', 2),
  (17, 'Stir It Up', 2),
  (18, 'Rainy day Women #12 & #35', 3),
  (19, 'Pledging my Time', 3),
  (20, 'Visions of Johanna', 3),
  (21, 'One of us must know',3),
  (22, 'I want you',3),
  (23, 'Stuck inside of Mobile..',3),
  (24, 'Leopard-skin pill-box hat',3),
  (25, 'Just like a woman',3),
  (26, "Most likely you'll go your way and I'll go mine",3),
  (27, 'Temporary like Achilles',3);
