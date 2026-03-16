# 🎓 Student Examination Management System (Database-Centric)

A professional, enterprise-level database solution developed for the **Information Technology Institute (ITI)**. This project implements a fully automated examination system where 100% of the business logic, security, and grading resides within **SQL Server Stored Procedures**.

---

## 📌 Project Context
This system is designed to manage the full examination lifecycle across multiple ITI branches. It moves away from traditional application-level logic by centralizing all "heavy lifting" (like random exam generation and automatic grading) inside the database layer using T-SQL.

---

## 🚀 Key Features
*   **Centralized Business Logic:** All operations are performed via Stored Procedures (T-SQL).
*   **Random Exam Engine:** Automatically generates unique exams for courses by shuffling MCQ and True/False questions.
*   **XML Data Handling:** Processes student answer submissions via SQL XML parsing.
*   **Transaction-Based Grading:** A secure grading engine that compares student choices against model answers using `BEGIN TRANSACTION` to ensure data integrity.
*   **Role-Based Access Control (RBAC):** Custom roles for Administrators, Instructors, and Students with a strict `DENY` rule on sensitive answer tables.
*   **Mandatory Reporting:** Real-time generation of student transcripts, department rosters, and instructor workload reports.

---

## 🛠 Technical Stack
*   **Engine:** Microsoft SQL Server 2019+
*   **Language:** T-SQL (Transact-SQL)
*   **Management:** SQL Server Management Studio (SSMS)
*   **Data Formats:** XML (for student answer submissions)

---
