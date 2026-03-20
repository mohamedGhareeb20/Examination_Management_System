import javax.swing.*;
import java.awt.*;
import java.sql.*;

public class LoginScreen extends JFrame {
    private JComboBox<String> roleDropdown;
    private JTextField txtUserName;
    private JButton btnLogin;

    public LoginScreen() {
        setTitle("ITI Exam System - Login");
        setSize(350, 200);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new GridLayout(3, 2, 10, 10));
        setLocationRelativeTo(null);

        add(new JLabel(" Select Role:"));
        roleDropdown = new JComboBox<>(new String[]{"Instructor", "Student", "Admin"});
        add(roleDropdown);

        add(new JLabel(" Full Name / Email:"));
        txtUserName = new JTextField(" "); // Default
        add(txtUserName);

        add(new JLabel("")); // Spacer
        btnLogin = new JButton("Login");
        add(btnLogin);

        btnLogin.addActionListener(e -> performLogin());
    }

    private void performLogin() {
        String role = roleDropdown.getSelectedItem().toString();
        String userInput = txtUserName.getText().trim();

        if (userInput.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter your name!");
            return;
        }

        // --- ADMIN LOGIN ---
        if (role.equals("Admin")) {
            if (userInput.equalsIgnoreCase("admin")) {
                this.dispose();
                new AdminDashboard().setVisible(true);
            } else {
                JOptionPane.showMessageDialog(this, "❌ Admin username is 'admin'", "Error", JOptionPane.ERROR_MESSAGE);
            }
            return;
        }

        // --- INSTRUCTOR & STUDENT LOGIN ---
        try (Connection conn = DBManager.getConnection()) {
            String query = "";
            if (role.equals("Instructor")) {
                query = "SELECT InstructorID FROM Instructor WHERE InstructorName = ? OR Email = ?";
            } else if (role.equals("Student")) {
                query = "SELECT StudentID FROM Student WHERE StudentName = ? OR Email = ?";
            }

            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setString(1, userInput);
            pstmt.setString(2, userInput);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int realUserId = rs.getInt(1);
                this.dispose(); // Close login screen

                if (role.equals("Instructor")) {
                    JOptionPane.showMessageDialog(null, "Welcome Instructor " + userInput + "!");
                    new InstructorDashboard(realUserId).setVisible(true);
                } else {
                    JOptionPane.showMessageDialog(null, "Welcome Student " + userInput + "!");
                    new StudentDashboard(realUserId).setVisible(true);
                }
            } else {
                JOptionPane.showMessageDialog(this, "❌ Error: " + role + " '" + userInput + "' not found!", "Login Failed", JOptionPane.ERROR_MESSAGE);
            }

        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Database Error: " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    public static void main(String[] args) {
        new LoginScreen().setVisible(true);
    }
}