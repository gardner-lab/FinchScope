SONGBIRD SPECIFIC BATCH JOBS

This directory contains code to align and process multi-day longitudinal studies from
FreedomScope Experiments in songbirds, aligning video within and across days.


Directory should be structured as follows:

BirdID--> data --> *mov folder --> mat -->
          template         gif


CODE INDEX:

FS_BatchJob_Pt01
This function goes through above-structured directory, and aligns video data to
a template song.

HELPER FUNCTIONS:

FS_BatchJob_TemplateMatch
This function is a modification of FS_TemplateMatch,
