// =====================================================================
// C / D. CRUD OPERATIONS
// Run 01_constraints.cypher and 02_load_data.cypher first.
// Run these one statement at a time for screenshots.
// =====================================================================

// ---------------------------------------------------------------------
// C1. CREATE - add a new student, link to a department and skills
// (Running it twice fails on the student_id uniqueness constraint,
//  which is the constraint doing its job as a primary key.)
// ---------------------------------------------------------------------
CREATE (s:Student {student_id:'S007', first_name:'Gokul', last_name:'Krishnan',
                   email:'gokul.krishnan@college.edu', cgpa:8.40, branch:'CSE',
                   city:'Madurai', state:'Tamil Nadu'})
WITH s
MATCH (d:Department {dept_id:'D01'})
MERGE (s)-[:BELONGS_TO]->(d)
WITH s, d
UNWIND ['Java','Python'] AS skill
MATCH (sk:Skill {name: skill})
MERGE (s)-[:HAS_SKILL]->(sk)
RETURN s, d, sk;

// C1b. CREATE - the new student applies for the Data Analyst job (O05).
// The application id is built from the student id + next sequence number.
MATCH (s:Student {student_id:'S007'}), (o:Opportunity {opportunity_id:'O05'})
WITH s, o, COUNT { (s)-[:SUBMITTED]->() } + 1 AS seq
CREATE (a:Application {app_id: s.student_id + '-' + toString(seq),
                       applied_date: date(), status:'Applied'})
CREATE (s)-[:SUBMITTED]->(a)-[:FOR]->(o)
RETURN s.first_name AS student, a.app_id AS app_id, o.title AS applied_for;

// ---------------------------------------------------------------------
// C2. UPDATE - record an interview result, then sync the application
// status. In DA2 this was done by a trigger; Neo4j has no triggers, so
// it is a second query.
// ---------------------------------------------------------------------
MATCH (:Application {app_id:'S002-1'})-[:HAS_INTERVIEW]->(i:Interview)
SET i.result = 'Selected'
RETURN i.interview_id, i.result;

MATCH (a:Application {app_id:'S002-1'})-[:HAS_INTERVIEW]->(i:Interview)
WHERE i.result IN ['Selected','Rejected']
SET a.status = i.result
RETURN a.app_id, a.status;

// C3. UPDATE - a property on a node (student's CGPA)
MATCH (s:Student {student_id:'S004'})
SET s.cgpa = 8.05
RETURN s.student_id, s.first_name, s.cgpa;

// C4. UPDATE - data on a relationship: student accepts an offer
MATCH (s:Student {student_id:'S002'})-[:SUBMITTED]->(a:Application {status:'Selected'})-[:FOR]->(o)
MERGE (s)-[r:ACCEPTED]->(o)
SET r.offer_accepted_date = date()
RETURN s.first_name, o.title, r.offer_accepted_date;

// ---------------------------------------------------------------------
// D1. READ - all applications received by TechNova
// (same result as the DA2 cursor procedure)
// ---------------------------------------------------------------------
MATCH (c:Company {company_id:'C01'})-[:OFFERS]->(o)<-[:FOR]-(a:Application)<-[:SUBMITTED]-(s:Student)
RETURN s.first_name AS student, a.app_id AS app_id, o.title AS opportunity, a.status AS status
ORDER BY a.app_id;

// D2. READ - students of a department with their skills
MATCH (s:Student)-[:BELONGS_TO]->(d:Department {name:'Computer Science'})
OPTIONAL MATCH (s)-[:HAS_SKILL]->(sk:Skill)
RETURN s.student_id, s.first_name + ' ' + s.last_name AS name, s.cgpa, collect(sk.name) AS skills
ORDER BY s.cgpa DESC;

// D3. READ - filter on a sub-label: internships paying at least 25000
MATCH (c:Company)-[:OFFERS]->(o:Internship)
WHERE o.stipend >= 25000
RETURN c.name AS company, o.title, o.stipend, o.duration_months
ORDER BY o.stipend DESC;

// D4. READ - students who have not applied anywhere
MATCH (s:Student)
WHERE NOT EXISTS { (s)-[:SUBMITTED]->(:Application) }
RETURN s.student_id, s.first_name, s.branch;

// D5. READ - application status of one student, with interview if any
MATCH (s:Student {student_id:'S001'})-[:SUBMITTED]->(a)-[:FOR]->(o)<-[:OFFERS]-(c)
OPTIONAL MATCH (a)-[:HAS_INTERVIEW]->(i)
RETURN a.app_id, c.name AS company, o.title, labels(o) AS type, a.status,
       i.interview_date AS interview_date, i.result AS interview_result
ORDER BY a.app_id;

// ---------------------------------------------------------------------
// D6. DELETE - withdraw an application together with its links
// ---------------------------------------------------------------------
MATCH (a:Application {app_id:'S005-2'})
DETACH DELETE a;

// Confirm it is gone (returns no rows)
MATCH (a:Application {app_id:'S005-2'}) RETURN a;

// D7. DELETE - remove a single relationship (student drops a skill)
MATCH (:Student {student_id:'S007'})-[r:HAS_SKILL]->(:Skill {name:'Python'})
DELETE r;

// D8. DELETE - remove a property
MATCH (s:Student {student_id:'S007'})
REMOVE s.city
RETURN s;
