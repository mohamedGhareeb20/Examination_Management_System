import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.Vector;

public class InstructorDashboard extends JFrame {
    private int loggedInInstructorId; // Variable to store the instructor's ID
    private JTextField txtCourseId, txtExamName, txtMCQ, txtTF;
    private JButton btnGenerate, btnViewExams, btnViewGrades, btnViewQuestions, btnWorkload, btnLogout;

    // Constructor now accepts the Instructor ID
    public InstructorDashboard(int instructorId) {
        this.loggedInInstructorId = instructorId;

        setTitle("Instructor Dashboard - ITI Exam System");
        setSize(500, 500);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Layout: 9 Rows, 2 Columns
        setLayout(new GridLayout(9, 2, 10, 10));
        setLocationRelativeTo(null);

        // --- SECTION 1: EXAM GENERATION ---
        add(new JLabel(" 📘 Course ID (e.g. 1):"));
        txtCourseId = new JTextField();
        add(txtCourseId);

        add(new JLabel(" 📝 Exam Name:"));
        txtExamName = new JTextField();
        add(txtExamName);

        add(new JLabel(" 🔢 Number of MCQs:"));
        txtMCQ = new JTextField();
        add(txtMCQ);

        add(new JLabel(" 🔢 Number of T/F:"));
        txtTF = new JTextField();
        add(txtTF);

        btnGenerate = new JButton("⚙️ Generate Random Exam");
        btnGenerate.setBackground(new Color(40, 167, 69)); // Green
        btnGenerate.setForeground(Color.WHITE);
        add(new JLabel("")); add(btnGenerate);

        // --- SECTION 2: REPORTING BUTTONS ---
        btnViewQuestions = new JButton("🔍 View Question Bank");
        btnViewExams = new JButton("📋 My Generated Exams");
        btnViewGrades = new JButton("🎓 View Student Grades");
        btnWorkload = new JButton("📊 My Course Statistics"); // REQ-14

        add(btnViewQuestions); add(btnViewExams);
        add(btnViewGrades);    add(btnWorkload);

        // --- SECTION 3: SYSTEM ---
        btnLogout = new JButton("Logout");
        btnLogout.setBackground(new Color(220, 53, 69)); // Red
        btnLogout.setForeground(Color.WHITE);
        add(new JLabel("")); add(btnLogout);

        // ==========================================================
        // ACTION LISTENERS
        // ==========================================================

        btnGenerate.addActionListener(e -> generateExam());

        btnViewQuestions.addActionListener(e -> showDataInTable(
                "Question Bank",
                "SELECT q.QuestionID, c.CourseName, q.QuestionText, q.Points FROM Question q JOIN Course c ON q.CourseID = c.CourseID ORDER BY q.QuestionID ASC"
        ));

        btnViewExams.addActionListener(e -> showDataInTable(
                "Generated Exams",
                "SELECT e.ExamID, e.ExamName, c.CourseName, e.TotalQuestions FROM Exam e JOIN Course c ON e.CourseID = c.CourseID"
        ));

        btnViewGrades.addActionListener(e -> showDataInTable(
                "Student Grades",
                "SELECT s.StudentName, e.ExamName, se.TotalGrade FROM StudentExam se JOIN Student s ON se.StudentID = s.StudentID JOIN Exam e ON se.ExamID = e.ExamID"
        ));

        // CALLING REQ-14: Instructor Workload Report
        btnWorkload.addActionListener(e -> {
            showDataInTable("My Student Statistics", "{call Report_InstructorCourses(" + loggedInInstructorId + ")}");
        });

        btnLogout.addActionListener(e -> {
            this.dispose();
            new LoginScreen().setVisible(true);
        });
    }

    private void generateExam() {
        try (Connection conn = DBManager.getConnection()) {
            CallableStatement stmt = conn.prepareCall("{call GenerateExam(?, ?, ?, ?)}");
            stmt.setInt(1, Integer.parseInt(txtCourseId.getText()));
            stmt.setString(2, txtExamName.getText());
            stmt.setInt(3, Integer.parseInt(txtMCQ.getText()));
            stmt.setInt(4, Integer.parseInt(txtTF.getText()));
            stmt.execute();
            JOptionPane.showMessageDialog(this, "✅ Exam Generated!");
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "❌ Error: " + ex.getMessage());
        }
    }

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
}