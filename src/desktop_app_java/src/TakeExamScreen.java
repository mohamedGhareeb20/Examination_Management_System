import javax.swing.*;
import java.sql.*;

public class TakeExamScreen {
    private int studentId;
    private int examId;
    private StringBuilder answersXml;

    public TakeExamScreen(int studentId, int examId) {
        this.studentId = studentId;
        this.examId = examId;
        this.answersXml = new StringBuilder("<Answers>");
    }

    public void startExam() {
        try (Connection conn = DBManager.getConnection()) {

            // --- 1. VALIDATION: Does this Exam exist? ---
            PreparedStatement checkExam = conn.prepareStatement("SELECT ExamName FROM Exam WHERE ExamID = ?");
            checkExam.setInt(1, examId);
            ResultSet rsExam = checkExam.executeQuery();
            if (!rsExam.next()) {
                JOptionPane.showMessageDialog(null, "❌ Error: Exam ID " + examId + " does not exist!", "Invalid Exam", JOptionPane.ERROR_MESSAGE);
                new StudentDashboard(studentId).setVisible(true); // Go back to dashboard
                return;
            }

            // --- 2. VALIDATION: Did the student already take this? ---
            PreparedStatement checkTaken = conn.prepareStatement("SELECT TotalGrade FROM StudentExam WHERE StudentID = ? AND ExamID = ?");
            checkTaken.setInt(1, studentId);
            checkTaken.setInt(2, examId);
            ResultSet rsTaken = checkTaken.executeQuery();
            if (rsTaken.next()) {
                JOptionPane.showMessageDialog(null, "⚠️ You have already taken this exam!\nYour previous grade was: " + rsTaken.getInt("TotalGrade"), "Already Taken", JOptionPane.WARNING_MESSAGE);
                new StudentDashboard(studentId).setVisible(true); // Go back to dashboard
                return;
            }

            // --- 3. FETCH & ASK QUESTIONS ---
            String query = "SELECT q.QuestionID, q.QuestionText FROM ExamQuestion eq JOIN Question q ON eq.QuestionID = q.QuestionID WHERE eq.ExamID = ?";
            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setInt(1, examId);
            ResultSet rs = pstmt.executeQuery();

            boolean hasQuestions = false;

            while (rs.next()) {
                hasQuestions = true;
                int qId = rs.getInt("QuestionID");
                String qText = rs.getString("QuestionText");

                // Fetch options
                String optQuery = "SELECT OptionID, OptionText FROM [Option] WHERE QuestionID = ?";
                PreparedStatement optStmt = conn.prepareStatement(optQuery);
                optStmt.setInt(1, qId);
                ResultSet optRs = optStmt.executeQuery();

                String display = "Question: " + qText + "\n\nOptions:\n";
                while (optRs.next()) {
                    display += optRs.getInt("OptionID") + ") " + optRs.getString("OptionText") + "\n";
                }
                display += "\nType the Option ID you choose:";

                // Ask student
                String answerStr = JOptionPane.showInputDialog(null, display, "Exam ID: " + examId + " | In Progress", JOptionPane.QUESTION_MESSAGE);

                // If they hit cancel or close the box, treat it as a skipped question
                if (answerStr == null) {
                    int confirm = JOptionPane.showConfirmDialog(null, "Are you sure you want to exit the exam early?", "Exit Exam", JOptionPane.YES_NO_OPTION);
                    if (confirm == JOptionPane.YES_OPTION) break; // End exam early
                } else if (!answerStr.trim().isEmpty()) {
                    int chosenOptionId = Integer.parseInt(answerStr.trim());
                    answersXml.append("<Answer><QuestionID>").append(qId)
                            .append("</QuestionID><ChosenOptionID>").append(chosenOptionId)
                            .append("</ChosenOptionID></Answer>");
                }
            }
            answersXml.append("</Answers>");

            if (!hasQuestions) {
                JOptionPane.showMessageDialog(null, "❌ Error: This exam has no questions attached to it.");
                new StudentDashboard(studentId).setVisible(true);
                return;
            }

            // --- 4. SUBMIT AND GRADE ---
            submitAndGradeExam(conn);

        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(null, "Database Error: " + e.getMessage());
        }
    }

    private void submitAndGradeExam(Connection conn) throws Exception {
        // A. Submit Answers
        CallableStatement submitStmt = conn.prepareCall("{call SubmitExamAnswers(?,?,?,?,?)}");
        submitStmt.setInt(1, studentId);
        submitStmt.setInt(2, examId);
        submitStmt.setTimestamp(3, new Timestamp(System.currentTimeMillis() - 3600000));
        submitStmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
        submitStmt.setString(5, answersXml.toString());
        submitStmt.execute();

        // B. Get the Attempt ID
        Statement stmt = conn.createStatement();
        ResultSet rsId = stmt.executeQuery("SELECT MAX(StudentExamID) AS AttemptID FROM StudentExam WHERE StudentID = " + studentId);
        rsId.next();
        int attemptId = rsId.getInt("AttemptID");

        // C. Correct Exam
        CallableStatement correctStmt = conn.prepareCall("{call CorrectExam(?)}");
        correctStmt.setInt(1, attemptId);
        correctStmt.execute();

        // D. Fetch Final Grade AND Max Possible Grade
        ResultSet rsGrade = stmt.executeQuery("SELECT TotalGrade FROM StudentExam WHERE StudentExamID = " + attemptId);
        rsGrade.next();
        int studentScore = rsGrade.getInt("TotalGrade");

        PreparedStatement maxGradeStmt = conn.prepareStatement("SELECT SUM(q.Points) AS MaxScore FROM ExamQuestion eq JOIN Question q ON eq.QuestionID = q.QuestionID WHERE eq.ExamID = ?");
        maxGradeStmt.setInt(1, examId);
        ResultSet rsMax = maxGradeStmt.executeQuery();
        rsMax.next();
        int maxScore = rsMax.getInt("MaxScore");

        // Show Final Result
        JOptionPane.showMessageDialog(null,
                "✅ Exam Submitted Successfully!\n\n🎓 Your Final Grade: " + studentScore + " / " + maxScore,
                "Exam Results",
                JOptionPane.INFORMATION_MESSAGE);

        // Reopen Student Dashboard so they can take another test if they want
        new StudentDashboard(studentId).setVisible(true);
    }
}