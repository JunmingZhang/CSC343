import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
            connection.setSchema("parlgov");
            return true;
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            return true;
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        ElectionCabinetResult result = null;
        try {
            List<Integer> elections = new ArrayList<Integer>();
            List<Integer> cabinets = new ArrayList<Integer>();

            String sqlText = "SELECT el.id AS electionId, ca.id AS cabinetId " +
                             "FROM cabinet ca, election el, country co " +
                             "WHERE co.name = ? AND " +
                             "co.id = ca.country_id AND " +
                             "el.id = ca.election_id " +
                             "ORDER BY (EXTRACT(year FROM e_date)) DESC";

            PreparedStatement ps = connection.prepareStatement(sqlText);
            ps.setString(1, countryName);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                elections.add(rs.getInt("electionId"));
                cabinets.add(rs.getInt("cabinetId"));
            }
            result = new ElectionCabinetResult(elections, cabinets);
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
        }
        return result;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        try {
            String selectedDescription = null;
            String selectedComment = null;
            List<Integer> result = new ArrayList<Integer>();

            String selectedPoliticianSQL = "SELECT description AS description1, comment AS comment1 " +
                                           "FROM politician_president poli_pr " +
                                           "WHERE poli_pr.id = ?";
    
            PreparedStatement ps1 = connection.prepareStatement(selectedPoliticianSQL);
            ps1.setInt(1, politicianName);
            ResultSet rs1 = ps1.executeQuery();

            while (rs1.next()) {
                selectedDescription = rs1.getString("description1");
                selectedComment = rs1.getString("comment1");
            }

            String selectedOtherPoliticiansSQL = "SELECT description AS description2, comment AS comment2, poli_pr.id AS PrId " +
                                                "FROM politician_president poli_pr " +
                                                "WHERE poli_pr.id <> ?";
            
            PreparedStatement ps2 = connection.prepareStatement(selectedOtherPoliticiansSQL);
            ps2.setInt(1, politicianName);
            ResultSet rs2 = ps2.executeQuery();

            while (rs2.next()) {
                int PrId = rs2.getInt("PrId");
                if (similarity(selectedDescription, rs2.getString("description2")) +
                    similarity(selectedComment, rs2.getString("comment2")) > threshold) {
                        result.add(PrId);
                    }
            }

            return result;
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            return null;
        }
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

