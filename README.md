# Course-Registry-Prerequisite-Detector

This prolog program lets users know if they are eligible to enrol in a course. 
Given a list of courses, each with prerequisite courses, this program either outputs:
  1) A list of courses that can be enrolled in, if presented a list of courses already taken.
  2) Whether or not a student is eligible to enrol in a specific course, based on the courses that they have already taken.
  
The program can also determine if a course is, by extension, its own prerequisite, and acts appropriately in such a case so that it does not end up looping indefinitely.
