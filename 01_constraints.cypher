// =====================================================================
// A. CONSTRAINTS  (uniqueness constraints act as primary keys)
// Internship and Placement Management System - DA3 (Neo4j)
// Run this file first.
// =====================================================================

CREATE CONSTRAINT student_id IF NOT EXISTS
FOR (s:Student) REQUIRE s.student_id IS UNIQUE;

CREATE CONSTRAINT dept_id IF NOT EXISTS
FOR (d:Department) REQUIRE d.dept_id IS UNIQUE;

CREATE CONSTRAINT faculty_id IF NOT EXISTS
FOR (f:FacultyCoordinator) REQUIRE f.faculty_id IS UNIQUE;

CREATE CONSTRAINT officer_id IF NOT EXISTS
FOR (p:PlacementOfficer) REQUIRE p.officer_id IS UNIQUE;

CREATE CONSTRAINT company_id IF NOT EXISTS
FOR (c:Company) REQUIRE c.company_id IS UNIQUE;

// One constraint covers both sub-labels (:Internship and :JobOffer),
// because every such node also carries the :Opportunity label.
CREATE CONSTRAINT opportunity_id IF NOT EXISTS
FOR (o:Opportunity) REQUIRE o.opportunity_id IS UNIQUE;

CREATE CONSTRAINT app_id IF NOT EXISTS
FOR (a:Application) REQUIRE a.app_id IS UNIQUE;

CREATE CONSTRAINT interview_id IF NOT EXISTS
FOR (i:Interview) REQUIRE i.interview_id IS UNIQUE;

CREATE CONSTRAINT skill_name IF NOT EXISTS
FOR (sk:Skill) REQUIRE sk.name IS UNIQUE;

// Check: should list 9 constraints
SHOW CONSTRAINTS;
