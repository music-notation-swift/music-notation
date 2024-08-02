# MuseScore internal score representation

This document gives an overview of how a score is represented in MuseScore. If you find it long on
generalities and short on details, consider that a good thing, as details tend to change rapidly. So
by keeping this fairly general, it is less likely to be out of date. This description was originally
created shortly before the release of MuseScore 2.0.

All of the source files referenced in this document are found in the “libmscore” subfolder of the
main repository unless otherwise noted.

## Score

A Score is the main top-level object. You can view `score.h` to see its definition. There are members
here to store the style settings and other options associated with the score, and there are all
sorts of other members to keep track of other things that seldom matter to most of the code. The
main thing that usually matters is the list of measures – that’s where almost everything about the
content of the score (even things like the title frame) are to be found. There is also a list of
staves – one staff for each instrument in your score, normally, except for instruments like piano
that may have two.

Aside from the lists of measures and staves, the next most interesting thing in a score are the
various “maps” that MuseScore builds to keep track of things that might change over the course of
the score – the time signatures, key signatures, tempo markings, etc. These allow code to quickly
ascertain the current time signature (or whatever) at any given point in the score. There is also a
map for elements called spanners – these are thing like slurs or crescendo markings that don’t just
live in one place in the score but instead span from one place to another.

The Score object also contains a list of the pages for the score and the systems that make up those
pages, but actually, these are not normally needed for most work. These data structures are created
and managed by the layout engine.

## Elements

In general, MuseScore is WYSIWYG, and if you see something on the page, there is probably an object
for it. Element is the base class for all such objects. Elements are organized in a tree-like
structure, where a Score contains Pages, each Page contains Systems, each System contains Measures,
each Measure contains Segments, each Segment contains Chords, each Chord contains Notes, etc. Each
element contains a pointer to its parent.

Elements generally have a layout() method to determine position and other charateristics; this is
often a significant part of the implementation of any given element. Some elements are more
abstract, like Staff, which defines the attributes of any given staff (number of lines, instrument
to use, etc) but are not actually drawn directly.

## Measures

As mentioned, the most important thing in a Score is the list of Measures. Actually, it’s a list of
MeasureBases – this is the base class for both measures and frames. But for many purposes, you can
ignore the frames. And even though measures are children of systems which are children of pages, you
normally access the measure list for a score directly.

A Measure object (`measure.h`) contains a bunch of members you are unlikely to care about. But just as
the most important member of the score is the list of measures, the most important member of a
measure is a list of segments. See below

## Segments

The Segment object (`segment.h`) is perhaps the most important data structure to understand in
MuseScore. A segment represents a moment in time – which, by the way, is represented in MuseScore in
units called “ticks” (480 of them per quarter note). A segment contains a list of elements that
occur at that time position across all staves. So if your score has four instruments, two of which
play a note at a particular moment in time, there will be elements for those two notes in the
segment. Each element in a segment contains an indication of what staff it lives on, also what voice
within the staff. Actually, these two pieces of information are combined into the notion of of
“track”. Tracks 0-3 are the four voices for the first staff, tracks 4-7 are the four voices for the
second staff, etc.

A segment contains an element for a given track only if something actually happens at the tick for
the segment. So for instance, if one staff has a whole note while another has two half notes, there
will be two segments total. The first segment, representing beat one (tick 0 within the measure)
will contain the whole note for the first staff and the first half note for the second staff. The
second segment, representing beat three (tick 960 within the measure), will contain the second half
note for the second staff but will contain nothing for the first staff.

A segment can also contain annotations – markings like staff text, chord symbols, dynamics, etc.
They also have a track to record what staff and voice they are associated with.

So far, I have been talking about one kind of segment only - the type that contains chords and rests
(or more generally, chordrests, the parent class of both chords and rests). There are also separate
segments for the clefs, time signatures, key signatures, and barlines. Much of the code in MuseScore
ignores these and focuses only on the chordrest segments.

## Chords

MuseScore makes a distinction between a chord and note that isn’t what you might expect. A Chord
(`chord.h`) is a collection of one or more notes on a given track (staff/voice) at a given tick
(moment in time). Basically, even single notes are chords to MuseScore. A chord has a list of the
notes that make up the chord, so that list will just contain a single element for single notes. By
definition, all notes of a chord share the same basic duration. Notes that occur at the same tick
but have different durations must be entered into different voices – that’s how MuseScore and most
other notation programs organize things both internally and in the user interface.

A chord has a duration and list of notes. It also has info about the stem, ledger lines, grace notes
to apply to the chord, articulations, arpeggio, tremolo, glissando, etc. Two chords tied together
are represented in MuseScore as two separate chords (each with its own duration) and a separate tie
object, just as it looks.

## Note

As mentioned, a chord has one or more notes. The Note object (`note.h`) is where you find information
about pitch, staff line, accidentals, playback information – anything that potentially
differentiates one note within a chord from another.

## Rest

The Rest object (`rest.h`) is a sibling of chord – they share the same parent, chordrest. A rest has a
duration and that’s about it. Full measure rests are represented with a special duration value, so
they can fill a measure of any time signature.
