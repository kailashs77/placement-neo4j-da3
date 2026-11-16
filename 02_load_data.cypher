// =====================================================================
// B. SAMPLE DATA LOAD
// 3 departments, 3 faculty coordinators, 2 placement officers,
// 4 companies, 6 opportunities (3 internships + 3 job offers), 6 skills,
// 6 students, 7 applications, 4 interviews  = 41 nodes
//
// Every node and relationship is created with MERGE on its key, so this
// script can be re-run without creating duplicates.
// Run 01_constraints.cypher before this file.
// =====================================================================

// ---------- B1. Departments ------------------------------------------
UNWIND [
  {dept_id:'D01', name:'Computer Science',              office_building:'Tech Block',  office_room:'T-201'},
  {dept_id:'D02', name:'Electronics and Communication', office_building:'Tech Block',  office_room:'T-305'},
  {dept_id:'D03', name:'Mechanical Engineering',        office_building:'Mech Block',  office_room:'M-110'}
] AS row
MERGE (d:Department {dept_id: row.dept_id})
SET d += row;

// ---------- B2. Faculty coordinators ---------------------------------
UNWIND [
  {faculty_id:'F01', first_name:'Anitha', last_name:'Raman', email:'anitha.raman@college.edu', department:'Computer Science'},
  {faculty_id:'F02', first_name:'Vikram', last_name:'Nair',  email:'vikram.nair@college.edu',  department:'Electronics and Communication'},
  {faculty_id:'F03', first_name:'Meena',  last_name:'Iyer',  email:'meena.iyer@college.edu',   department:'Mechanical Engineering'}
] AS row
MERGE (f:FacultyCoordinator {faculty_id: row.faculty_id})
SET f += row;

// ---------- B3. Placement officers -----------------------------------
UNWIND [
  {officer_id:'P01', first_name:'Ramesh',  last_name:'Kumar', email:'ramesh.kumar@college.edu',  phone:'9840011111'},
  {officer_id:'P02', first_name:'Lakshmi', last_name:'Menon', email:'lakshmi.menon@college.edu', phone:'9840022222'}
] AS row
MERGE (p:PlacementOfficer {officer_id: row.officer_id})
SET p += row;

// ---------- B4. Companies --------------------------------------------
// Multivalued Phone_Numbers -> list property (replaces COMPANY_PHONE table)
// Composite Location / HR_Contact -> separate properties
UNWIND [
  {company_id:'C01', name:'TechNova',         industry:'Software',      city:'Chennai',   state:'Tamil Nadu',
   hr_name:'Sanjay Rao',    hr_email:'hr@technova.example',   phone_numbers:['044-40001111','9000011111']},
  {company_id:'C02', name:'DataSphere',       industry:'Analytics',     city:'Bengaluru', state:'Karnataka',
   hr_name:'Nisha Kapoor',  hr_email:'hr@datasphere.example', phone_numbers:['080-40002222']},
  {company_id:'C03', name:'GreenGrid Energy', industry:'Energy / IoT',  city:'Hyderabad', state:'Telangana',
   hr_name:'Farhan Ali',    hr_email:'hr@greengrid.example',  phone_numbers:['040-40003333','9000033333']},
  {company_id:'C04', name:'AutoMech Systems', industry:'Automotive',    city:'Pune',      state:'Maharashtra',
   hr_name:'Pooja Deshmukh', hr_email:'hr@automech.example',  phone_numbers:['020-40004444']}
] AS row
MERGE (c:Company {company_id: row.company_id})
SET c += row;

// ---------- B5. Skills (shared nodes) --------------------------------
UNWIND ['Java','Python','SQL','Machine Learning','Embedded C','AutoCAD'] AS name
MERGE (:Skill {name: name});

// ---------- B6. Opportunities: internships ---------------------------
// ISA hierarchy -> two labels on one node (:Opportunity:Internship)
UNWIND [
  {opportunity_id:'O01', title:'Backend Developer Intern',  stipend:25000, duration_months:6, deadline:date('2026-08-31')},
  {opportunity_id:'O02', title:'Data Science Intern',       stipend:30000, duration_months:6, deadline:date('2026-09-05')},
  {opportunity_id:'O03', title:'Embedded Systems Intern',   stipend:20000, duration_months:4, deadline:date('2026-09-10')}
] AS row
MERGE (o:Opportunity {opportunity_id: row.opportunity_id})
SET o:Internship, o += row;

// ---------- B7. Opportunities: job offers ----------------------------
UNWIND [
  {opportunity_id:'O04', title:'Software Engineer', package_lpa:8.5, job_type:'Full-time', deadline:date('2026-09-15')},
  {opportunity_id:'O05', title:'Data Analyst',      package_lpa:7.0, job_type:'Full-time', deadline:date('2026-09-20')},
  {opportunity_id:'O06', title:'Design Engineer',   package_lpa:6.0, job_type:'Full-time', deadline:date('2026-09-25')}
] AS row
MERGE (o:Opportunity {opportunity_id: row.opportunity_id})
SET o:JobOffer, o += row;

// ---------- B8. Students ---------------------------------------------
UNWIND [
  {student_id:'S001', first_name:'Arjun',   last_name:'Sharma', email:'arjun.sharma@college.edu',  cgpa:8.90, branch:'CSE',  city:'Chennai',    state:'Tamil Nadu'},
  {student_id:'S002', first_name:'Priya',   last_name:'Nair',   email:'priya.nair@college.edu',    cgpa:9.10, branch:'CSE',  city:'Kochi',      state:'Kerala'},
  {student_id:'S003', first_name:'Karthik', last_name:'Reddy',  email:'karthik.reddy@college.edu', cgpa:8.20, branch:'ECE',  city:'Hyderabad',  state:'Telangana'},
  {student_id:'S004', first_name:'Divya',   last_name:'Menon',  email:'divya.menon@college.edu',   cgpa:7.80, branch:'ECE',  city:'Coimbatore', state:'Tamil Nadu'},
  {student_id:'S005', first_name:'Rahul',   last_name:'Verma',  email:'rahul.verma@college.edu',   cgpa:8.00, branch:'CSE',  city:'Bengaluru',  state:'Karnataka'},
  {student_id:'S006', first_name:'Sneha',   last_name:'Pillai', email:'sneha.pillai@college.edu',  cgpa:8.50, branch:'MECH', city:'Pune',       state:'Maharashtra'}
] AS row
MERGE (s:Student {student_id: row.student_id})
SET s += row;

// ---------- B9. Applications (weak entity: id built from student) ----
UNWIND [
  {app_id:'S001-1', applied_date:date('2026-08-10'), status:'Selected'},
  {app_id:'S001-2', applied_date:date('2026-08-12'), status:'Under Review'},
  {app_id:'S002-1', applied_date:date('2026-08-11'), status:'Interview Scheduled'},
  {app_id:'S003-1', applied_date:date('2026-08-14'), status:'Selected'},
  {app_id:'S005-1', applied_date:date('2026-08-13'), status:'Rejected'},
  {app_id:'S005-2', applied_date:date('2026-08-20'), status:'Applied'},
  {app_id:'S006-1', applied_date:date('2026-08-22'), status:'Applied'}
] AS row
MERGE (a:Application {app_id: row.app_id})
SET a += row;

// ---------- B10. Interviews (weak entity: id built from application) -
UNWIND [
  {interview_id:'S001-1-1', round:'Technical', mode:'Online',  interview_date:date('2026-09-18'), result:'Selected'},
  {interview_id:'S002-1-1', round:'Technical', mode:'Online',  interview_date:date('2026-09-22'), result:'Pending'},
  {interview_id:'S003-1-1', round:'Technical', mode:'Offline', interview_date:date('2026-09-16'), result:'Selected'},
  {interview_id:'S005-1-1', round:'Technical', mode:'Online',  interview_date:date('2026-09-08'), result:'Rejected'}
] AS row
MERGE (i:Interview {interview_id: row.interview_id})
SET i += row;

// =====================================================================
// RELATIONSHIPS (10 types)
// =====================================================================

// ---------- R1. (Student)-[:BELONGS_TO]->(Department) ----------------
UNWIND [
  ['S001','D01'], ['S002','D01'], ['S005','D01'],
  ['S003','D02'], ['S004','D02'],
  ['S006','D03']
] AS pair
MATCH (s:Student {student_id: pair[0]}), (d:Department {dept_id: pair[1]})
MERGE (s)-[:BELONGS_TO]->(d);

// ---------- R2. (FacultyCoordinator)-[:GUIDES]->(Student) ------------
UNWIND [
  ['F01','S001'], ['F01','S002'], ['F01','S005'],
  ['F02','S003'], ['F02','S004'],
  ['F03','S006']
] AS pair
MATCH (f:FacultyCoordinator {faculty_id: pair[0]}), (s:Student {student_id: pair[1]})
MERGE (f)-[:GUIDES]->(s);

// ---------- R3. (PlacementOfficer)-[:MANAGES]->(Company)  M:N --------
// Direct relationship replaces the MANAGES junction table
UNWIND [
  ['P01','C01'], ['P01','C02'],
  ['P02','C02'], ['P02','C03'], ['P02','C04']
] AS pair
MATCH (p:PlacementOfficer {officer_id: pair[0]}), (c:Company {company_id: pair[1]})
MERGE (p)-[:MANAGES]->(c);

// ---------- R4. (Company)-[:OFFERS]->(Opportunity) -------------------
// One type for both OFFERS (internship) and PROVIDES (job offer)
UNWIND [
  ['C01','O01'], ['C01','O04'],
  ['C02','O02'], ['C02','O05'],
  ['C03','O03'],
  ['C04','O06']
] AS pair
MATCH (c:Company {company_id: pair[0]}), (o:Opportunity {opportunity_id: pair[1]})
MERGE (c)-[:OFFERS]->(o);

// ---------- R5. (Student)-[:HAS_SKILL]->(Skill) ----------------------
// Replaces the STUDENT_SKILLS table
UNWIND [
  ['S001','Java'], ['S001','SQL'], ['S001','Python'],
  ['S002','Python'], ['S002','Machine Learning'], ['S002','SQL'],
  ['S003','Embedded C'], ['S003','Python'],
  ['S004','Embedded C'],
  ['S005','Java'], ['S005','Python'], ['S005','SQL'],
  ['S006','AutoCAD']
] AS pair
MATCH (s:Student {student_id: pair[0]}), (sk:Skill {name: pair[1]})
MERGE (s)-[:HAS_SKILL]->(sk);

// ---------- R6. (Opportunity)-[:REQUIRES_SKILL]->(Skill) -------------
// Replaces the INTERNSHIP_SKILLS table (and works for job offers too)
UNWIND [
  ['O01','Java'], ['O01','SQL'],
  ['O02','Python'], ['O02','Machine Learning'],
  ['O03','Embedded C'], ['O03','Python'],
  ['O04','Java'], ['O04','Python'], ['O04','SQL'],
  ['O05','SQL'], ['O05','Python'],
  ['O06','AutoCAD']
] AS pair
MATCH (o:Opportunity {opportunity_id: pair[0]}), (sk:Skill {name: pair[1]})
MERGE (o)-[:REQUIRES_SKILL]->(sk);

// ---------- R7 + R8. (Student)-[:SUBMITTED]->(Application)-[:FOR]->(Opportunity)
// One FOR type replaces APPLIES_FOR / APPLIES_FOR_JOB and the nullable
// Internship_ID / Offer_ID columns of APPLICATION
UNWIND [
  ['S001','S001-1','O04'],
  ['S001','S001-2','O01'],
  ['S002','S002-1','O02'],
  ['S003','S003-1','O03'],
  ['S005','S005-1','O01'],
  ['S005','S005-2','O05'],
  ['S006','S006-1','O06']
] AS t
MATCH (s:Student {student_id: t[0]}),
      (a:Application {app_id: t[1]}),
      (o:Opportunity {opportunity_id: t[2]})
MERGE (s)-[:SUBMITTED]->(a)
MERGE (a)-[:FOR]->(o);

// ---------- R9. (Application)-[:HAS_INTERVIEW]->(Interview) ----------
UNWIND [
  ['S001-1','S001-1-1'],
  ['S002-1','S002-1-1'],
  ['S003-1','S003-1-1'],
  ['S005-1','S005-1-1']
] AS pair
MATCH (a:Application {app_id: pair[0]}), (i:Interview {interview_id: pair[1]})
MERGE (a)-[:HAS_INTERVIEW]->(i);

// ---------- R10. (Student)-[:ACCEPTED {offer_accepted_date}]->(Opportunity)
// RECEIVES + Offer_Accepted_Date: the date lives on the relationship
UNWIND [
  {student_id:'S001', opportunity_id:'O04', accepted:date('2026-09-25')},
  {student_id:'S003', opportunity_id:'O03', accepted:date('2026-09-20')}
] AS row
MATCH (s:Student {student_id: row.student_id}), (o:Opportunity {opportunity_id: row.opportunity_id})
MERGE (s)-[r:ACCEPTED]->(o)
SET r.offer_accepted_date = row.accepted;

// =====================================================================
// VERIFY THE LOAD
// =====================================================================

// Node count per label - total should be 41
// (Internship / JobOffer rows are sub-labels of the 6 Opportunity nodes)
MATCH (n)
UNWIND labels(n) AS label
RETURN label, count(*) AS nodes
ORDER BY label;

// Relationship count per type - should list 10 types
MATCH ()-[r]->()
RETURN type(r) AS relationship, count(*) AS total
ORDER BY relationship;
