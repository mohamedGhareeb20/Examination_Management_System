import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.Vector;

public class AdminDashboard extends JFrame {

    public AdminDashboard() {
        setTitle("Admin Dashboard - ITI System Management");
        setSize(700, 500);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Professional Grid Layout: 6 Rows, 3 Columns
        setLayout(new GridLayout(6, 3, 10, 10));
        setLocationRelativeTo(null);

        // --- ROW 1: Students ---
        JButton btnViewStudents = new JButton("👁️ View Students");
        JButton btnAddStudent = new JButton("➕ Add Student");
        JButton btnDelStudent = new JButton("❌ Delete Student");

        // --- ROW 2: Instructors ---
        JButton btnViewInstructors = new JButton("👁️ View Instructors");
        JButton btnAddInstructor = new JButton("➕ Add Instructor");
        JButton btnDelInstructor = new JButton("❌ Delete Instructor");

        // --- ROW 3: Courses ---
        JButton btnViewCourses = new JButton("👁️ View Courses");
        JButton btnAddCourse = new JButton("➕ Add Course");
        JButton btnDelCourse = new JButton("❌ Delete Course");

        // --- ROW 4: Infrastructure (Tracks & Branches) ---
        JButton btnViewTracks = new JButton("🛤️ View Tracks");
        JButton btnViewBranches = new JButton("🏢 View Branches");
        JButton btnViewEnrollments = new JButton("📑 View Enrollments");

        // --- ROW 5: Assignments (Mapping Junction Tables) ---
        JButton btnAssignStudent = new JButton("🔗 Enroll Student -> Track");
        JButton btnAssignInstructor = new JButton("🔗 Assign Instructor -> Course");
        JButton btnLogout = new JButton("Logout");

        JButton btnDeptReport = new JButton("📊 Report: Students by Dept");

        // Styling the Logout Button
        btnLogout.setBackground(new Color(220, 53, 69));
        btnLogout.setForeground(Color.WHITE);
        btnLogout.setFont(new Font("Arial", Font.BOLD, 12));

        // Adding all buttons to the dashboard
        add(btnViewStudents); add(btnAddStudent); add(btnDelStudent);
        add(btnViewInstructors); add(btnAddInstructor); add(btnDelInstructor);
        add(btnViewCourses); add(btnAddCourse); add(btnDelCourse);
        add(btnViewTracks); add(btnViewBranches); add(btnViewEnrollments);
        add(btnAssignStudent); add(btnAssignInstructor);  add(btnDeptReport); add(btnLogout);

        // ==========================================================
        // ACTION LISTENERS - VIEWING DATA (Dynamic JTable)
        // ==========================================================
        btnViewStudents.addActionListener(e -> showDataInTable("All Students", "SELECT StudentID, StudentName, Email, Phone FROM Student"));
        btnViewInstructors.addActionListener(e -> showDataInTable("All Instructors", "SELECT InstructorID, InstructorName, Email, DepartmentNo FROM Instructor"));
        btnViewCourses.addActionListener(e -> showDataInTable("All Courses", "SELECT CourseID, CourseName, MinDegree, MaxDegree FROM Course"));
        btnViewBranches.addActionListener(e -> showDataInTable("All Branches", "SELECT * FROM Branch"));
        btnViewTracks.addActionListener(e -> showDataInTable("Tracks", "SELECT t.TrackID, t.TrackName, b.BranchName FROM Track t JOIN Branch b ON t.BranchID = b.BranchID"));
        btnViewEnrollments.addActionListener(e -> showDataInTable("Current Enrollments", "SELECT s.StudentName, t.TrackName FROM Student_Track st JOIN Student s ON st.StudentID = s.StudentID JOIN Track t ON st.TrackID = t.TrackID"));

        // ==========================================================
        // ACTION LISTENERS - ASSIGNMENTS (Junction Tables)
        // ==========================================================
        btnAssignStudent.addActionListener(e -> {
            String sId = JOptionPane.showInputDialog(this, "Enter Student ID:");
            String tId = JOptionPane.showInputDialog(this, "Enter Track ID:");
            if (sId != null && tId != null) executeAssignment("{call AssignStudentToTrack(?, ?)}", Integer.parseInt(sId), Integer.parseInt(tId));
        });

        btnAssignInstructor.addActionListener(e -> {
            String iId = JOptionPane.showInputDialog(this, "Enter Instructor ID:");
            String cId = JOptionPane.showInputDialog(this, "Enter Course ID:");
            if (iId != null && cId != null) executeAssignment("{call AssignInstructorToCourse(?, ?)}", Integer.parseInt(iId), Integer.parseInt(cId));
        });

        // ==========================================================
        // ACTION LISTENERS - CRUD (Add / Delete)
        // ==========================================================
        btnAddStudent.addActionListener(e -> {
            String name = JOptionPane.showInputDialog(this, "Enter Student Name:");
            String email = JOptionPane.showInputDialog(this, "Enter Student Email:");
            String phone = JOptionPane.showInputDialog(this, "Enter Student Phone:");
            if (name != null) executeInsert("{call InsertStudent(?, ?, ?)}", name, email, phone);
        });

        btnAddInstructor.addActionListener(e -> {
            String name = JOptionPane.showInputDialog(this, "Enter Instructor Name:");
            String email = JOptionPane.showInputDialog(this, "Enter Instructor Email:");
            String dept = JOptionPane.showInputDialog(this, "Enter Dept Number:");
            if (name != null) executeInsert("{call InsertInstructor(?, ?, ?)}", name, email, dept);
        });

        btnAddCourse.addActionListener(e -> {
            String name = JOptionPane.showInputDialog(this, "Enter Course Name:");
            String min = JOptionPane.showInputDialog(this, "Enter Min Degree:");
            String max = JOptionPane.showInputDialog(this, "Enter Max Degree:");
            if (name != null) executeInsert("{call InsertCourse(?, ?, ?)}", name, min, max);
        });

        btnDelStudent.addActionListener(e -> deleteRecord("DELETE FROM Student WHERE StudentID = ?", "Student ID"));
        btnDelInstructor.addActionListener(e -> deleteRecord("DELETE FROM Instructor WHERE InstructorID = ?", "Instructor ID"));
        btnDelCourse.addActionListener(e -> deleteRecord("DELETE FROM Course WHERE CourseID = ?", "Course ID"));

        btnLogout.addActionListener(e -> {
            this.dispose();
            new LoginScreen().setVisible(true);
        });

        btnDeptReport.addActionListener(e -> {
            String deptNo = JOptionPane.showInputDialog(this, "Enter Department Number (e.g. 10):");
            if (deptNo != null && !deptNo.isEmpty()) {
                // This calls the exact Report procedure from SRS REQ-12
                showDataInTable("Students in Dept " + deptNo, "{call Report_StudentsByDepartment(" + deptNo + ")}");
            }
        });
    }

    // -------------------------------------------------------------------------
    // UTILITY: SHOW DATA IN TABLE
    // -------------------------------------------------------------------------
    private void showDataInTable(String title, String query) {
        try (Connection conn = DBManager.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
            ResultSetMetaData metaData = rs.getMetaData();
            Vector<String> colNames = new Vector<>();
            for (int i = 1; i <= metaData.getColumnCount(); i++) colNames.add(metaData.getColumnName(i));
            Vector<Vector<Object>> data = new Vector<>();
            while (rs.next()) {
                Vector<Object> row = new Vector<>();
                for (int i = 1; i <= metaData.getColumnCount(); i++) row.add(rs.getObject(i));
                data.add(row);
            }
            JTable table = new JTable(new DefaultTableModel(data, colNames));
            JFrame frame = new JFrame(title);
            frame.setSize(600, 400);
            frame.add(new JScrollPane(table));
            frame.setLocationRelativeTo(this);
            frame.setVisible(true);
        } catch (Exception ex) { JOptionPane.showMessageDialog(this, "Error: " + ex.getMessage()); }
    }

    // -------------------------------------------------------------------------
    // UTILITY: EXECUTE INSERTS (Calls Stored Procedures)
    // -------------------------------------------------------------------------
    private void executeInsert(String sp, String p1, String p2, String p3) {
        try (Connection conn = DBManager.getConnection()) {
            CallableStatement stmt = conn.prepareCall(sp);
            stmt.setString(1, p1);
            stmt.setString(2, p2);
            // Handle numeric params for Course/Instructor
            if (sp.contains("Course") || sp.contains("Instructor")) stmt.setInt(3, Integer.parseInt(p3));
            else stmt.setString(3, p3);
            stmt.execute();
            JOptionPane.showMessageDialog(this, "✅ Successfully added to Database!");
        } catch (Exception ex) { JOptionPane.showMessageDialog(this, "❌ Error: " + ex.getMessage()); }
    }

    // -------------------------------------------------------------------------
    // UTILITY: EXECUTE ASSIGNMENTS (Junction Tables)
    // -------------------------------------------------------------------------
    private void executeAssignment(String sp, int id1, int id2) {
        try (Connection conn = DBManager.getConnection()) {
            CallableStatement stmt = conn.prepareCall(sp);
            stmt.setInt(1, id1);
            stmt.setInt(2, id2);
            stmt.execute();
            JOptionPane.showMessageDialog(this, "✅ Link created successfully!");
        } catch (Exception ex) { JOptionPane.showMessageDialog(this, "❌ Error: Link failed. Check if IDs exist."); }
    }

    // -------------------------------------------------------------------------
    // UTILITY: DELETE RECORDS
    // -------------------------------------------------------------------------
    private void deleteRecord(String query, String label) {
        String idStr = JOptionPane.showInputDialog(this, "Enter " + label + " to delete:");
        if (idStr == null || idStr.isEmpty()) return;
        try (Connection conn = DBManager.getConnection()) {
            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setInt(1, Integer.parseInt(idStr));
            int rows = pstmt.executeUpdate();
            if (rows > 0) JOptionPane.showMessageDialog(this, "✅ Record Deleted.");
            else JOptionPane.showMessageDialog(this, "⚠️ ID not found.");
        } catch (Exception ex) { JOptionPane.showMessageDialog(this, "❌ Error: Cannot delete. Record is linked to existing Exams or Tracks."); }
    }
}