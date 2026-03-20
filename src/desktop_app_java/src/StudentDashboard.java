import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.Vector;

public class StudentDashboard extends JFrame {
    private int loggedInStudentId;
    private JTextField txtExamId;
    private JButton btnStartExam, btnViewTranscript, btnLogout;

    public StudentDashboard(int studentId) {
        this.loggedInStudentId = studentId;

        setTitle("Student Portal - Welcome Student #" + studentId);
        setSize(400, 250);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Using a Panel for the Exam Entry
        JPanel mainPanel = new JPanel(new GridLayout(4, 1, 10, 10));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        // Row 1: Exam ID Entry
        JPanel row1 = new JPanel(new FlowLayout());
        row1.add(new JLabel("Enter Exam ID: "));
        txtExamId = new JTextField(10);
        row1.add(txtExamId);
        mainPanel.add(row1);

        // Row 2: Action Buttons
        btnStartExam = new JButton("✍️ Start New Exam");
        btnStartExam.setBackground(new Color(0, 123, 255)); // Bright Blue
        btnStartExam.setForeground(Color.WHITE);
        mainPanel.add(btnStartExam);

        btnViewTranscript = new JButton("📊 View My Transcript");
        mainPanel.add(btnViewTranscript);

        // Row 3: Logout
        btnLogout = new JButton("Logout");
        btnLogout.setBackground(new Color(220, 53, 69)); // Red
        btnLogout.setForeground(Color.WHITE);
        mainPanel.add(btnLogout);

        add(mainPanel);
        setLocationRelativeTo(null);

        // ==========================================================
        // ACTION LISTENERS
        // ==========================================================

        // 1. START EXAM
        btnStartExam.addActionListener(e -> {
            String idText = txtExamId.getText().trim();
            if (idText.isEmpty()) {
                JOptionPane.showMessageDialog(this, "Please enter an Exam ID!");
                return;
            }
            try {
                int examId = Integer.parseInt(idText);
                this.dispose(); // Close dashboard

                // Launch the Exam Logic
                TakeExamScreen examScreen = new TakeExamScreen(loggedInStudentId, examId);
                examScreen.startExam();
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this, "Exam ID must be a number!");
            }
        });

        // 2. VIEW TRANSCRIPT (Calls REQ-13 Stored Procedure)
        btnViewTranscript.addActionListener(e -> viewTranscript());

        // 3. LOGOUT
        btnLogout.addActionListener(e -> {
            this.dispose();
            new LoginScreen().setVisible(true);
        });
    }

    // -------------------------------------------------------------------------
    // METHOD: VIEW TRANSCRIPT (Uses JTable for Production Look)
    // -------------------------------------------------------------------------
    private void viewTranscript() {
        try (Connection conn = DBManager.getConnection()) {
            // Calling the exact Reporting SP from the SRS (REQ-13)
            CallableStatement stmt = conn.prepareCall("{call Report_StudentGrades(?)}");
            stmt.setInt(1, loggedInStudentId);
            ResultSet rs = stmt.executeQuery();

            // Extract Data for the Table
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            Vector<String> columnNames = new Vector<>();
            for (int i = 1; i <= columnCount; i++) columnNames.add(metaData.getColumnName(i));

            Vector<Vector<Object>> data = new Vector<>();
            while (rs.next()) {
                Vector<Object> row = new Vector<>();
                for (int i = 1; i <= columnCount; i++) row.add(rs.getObject(i));
                data.add(row);
            }

            // UI Setup
            JTable table = new JTable(new DefaultTableModel(data, columnNames));
            table.setEnabled(false); // Read-only
            JScrollPane scrollPane = new JScrollPane(table);

            JFrame transcriptFrame = new JFrame("My Grades & Transcript");
            transcriptFrame.setSize(600, 300);
            transcriptFrame.add(scrollPane);
            transcriptFrame.setLocationRelativeTo(this);
            transcriptFrame.setVisible(true);

        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error loading transcript: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            ex.printStackTrace();
        }
    }
}