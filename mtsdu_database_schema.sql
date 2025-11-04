-- MTS DU School Management System Database Schema
-- This SQL file defines the complete database structure based on the Flutter project models.
-- It includes tables for users, subjects, classes, schedules, attendance, grades, assignments, announcements, and payments.
-- Enums are handled using CHECK constraints or separate tables if needed, but here using VARCHAR for simplicity.
-- Primary keys are auto-incrementing integers for simplicity, but can be adjusted to UUID if needed.
-- Foreign keys are defined to maintain referential integrity.

-- Enable foreign key constraints (SQLite specific, adjust for other databases)
PRAGMA foreign_keys = ON;

-- Users table (covers User, Student, Teacher models)
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Store hashed passwords
    role VARCHAR(10) NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    profile_image_path VARCHAR(255),
    contact VARCHAR(20),
    class_name VARCHAR(50), -- For students
    major VARCHAR(50), -- For students
    nip VARCHAR(20), -- For teachers
    subject VARCHAR(100) -- For teachers
);

-- Subjects table
CREATE TABLE subjects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    teacher_id INTEGER NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Classes table (ClassModel)
CREATE TABLE classes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL, -- e.g., "10A"
    major VARCHAR(50) NOT NULL, -- e.g., "IPA"
    homeroom_teacher_id INTEGER NOT NULL,
    FOREIGN KEY (homeroom_teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Schedules table
CREATE TABLE schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject VARCHAR(100) NOT NULL,
    assigned_to_id INTEGER NOT NULL, -- Can be teacher or student ID
    class_name VARCHAR(50) NOT NULL,
    day VARCHAR(10) NOT NULL CHECK (day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    time VARCHAR(20) NOT NULL, -- e.g., "08:00-09:00"
    room VARCHAR(50) NOT NULL,
    schedule_type VARCHAR(10) NOT NULL CHECK (schedule_type IN ('teacher', 'student')),
    FOREIGN KEY (assigned_to_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Attendance table
CREATE TABLE attendance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    subject VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('present', 'absent', 'late')),
    teacher_id INTEGER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(student_id, subject, date) -- Prevent duplicate attendance per student per subject per date
);

-- Grades table
CREATE TABLE grades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    subject VARCHAR(100) NOT NULL,
    assignment VARCHAR(100) NOT NULL,
    score REAL NOT NULL CHECK (score >= 0 AND score <= 100),
    date DATE NOT NULL,
    teacher_id INTEGER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Assignments table
CREATE TABLE assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    subject VARCHAR(100) NOT NULL,
    teacher_id INTEGER NOT NULL,
    class_name VARCHAR(50) NOT NULL,
    major VARCHAR(50) NOT NULL,
    due_date DATE NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Announcements table
CREATE TABLE announcements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    author_id INTEGER NOT NULL,
    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    target_role VARCHAR(10) NOT NULL CHECK (target_role IN ('student', 'teacher', 'admin', 'all')),
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Payments table
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    month VARCHAR(20) NOT NULL, -- e.g., "January"
    year INTEGER NOT NULL,
    amount REAL NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('paid', 'unpaid', 'overdue')),
    payment_date DATE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(student_id, month, year) -- Prevent duplicate payments per student per month/year
);

-- Indexes for better performance
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_subjects_teacher_id ON subjects(teacher_id);
CREATE INDEX idx_classes_homeroom_teacher_id ON classes(homeroom_teacher_id);
CREATE INDEX idx_schedules_assigned_to_id ON schedules(assigned_to_id);
CREATE INDEX idx_schedules_class_name ON schedules(class_name);
CREATE INDEX idx_attendance_student_id ON attendance(student_id);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_grades_student_id ON grades(student_id);
CREATE INDEX idx_grades_subject ON grades(subject);
CREATE INDEX idx_assignments_teacher_id ON assignments(teacher_id);
CREATE INDEX idx_assignments_class_name ON assignments(class_name);
CREATE INDEX idx_announcements_author_id ON announcements(author_id);
CREATE INDEX idx_announcements_target_role ON announcements(target_role);
CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Sample data insertion (optional, for testing)
-- Insert sample users
INSERT INTO users (username, password, role, name, email, contact, class_name, major, nip, subject) VALUES
('admin', 'hashed_password', 'admin', 'Administrator', 'admin@mtsdu.com', '08123456789', NULL, NULL, NULL, NULL),
('teacher1', 'hashed_password', 'teacher', 'Mr. Guru', 'guru@mtsdu.com', '08123456790', NULL, NULL, '12345', 'Mathematics'),
('student1', 'hashed_password', 'student', 'John Doe', 'john@mtsdu.com', '08123456791', '10A', 'IPA', NULL, NULL);

-- Insert sample subject
INSERT INTO subjects (name, description, teacher_id) VALUES
('Mathematics', 'Basic mathematics course', 2);

-- Insert sample class
INSERT INTO classes (name, major, homeroom_teacher_id) VALUES
('10A', 'IPA', 2);

-- Insert sample schedule
INSERT INTO schedules (subject, assigned_to_id, class_name, day, time, room, schedule_type) VALUES
('Mathematics', 2, '10A', 'Monday', '08:00-09:00', 'Room 101', 'teacher');

-- Insert sample attendance
INSERT INTO attendance (student_id, subject, date, status, teacher_id) VALUES
(3, 'Mathematics', '2023-10-01', 'present', 2);

-- Insert sample grade
INSERT INTO grades (student_id, subject, assignment, score, date, teacher_id) VALUES
(3, 'Mathematics', 'Homework 1', 85.5, '2023-10-01', 2);

-- Insert sample assignment
INSERT INTO assignments (title, description, subject, teacher_id, class_name, major, due_date) VALUES
('Homework 1', 'Solve math problems', 'Mathematics', 2, '10A', 'IPA', '2023-10-10');

-- Insert sample announcement
INSERT INTO announcements (title, content, author_id, target_role) VALUES
('Welcome', 'Welcome to MTS DU', 1, 'all');

-- Insert sample payment
INSERT INTO payments (student_id, month, year, amount, status, payment_date) VALUES
(3, 'October', 2023, 500000, 'paid', '2023-10-01');
