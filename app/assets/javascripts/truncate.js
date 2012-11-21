function truncate(text, length, ellipsis) {
 
// Set length and ellipsis to defaults if not defined
if (typeof length == 'undefined') var length = 100;
if (typeof ellipsis == 'undefined') var ellipsis = '...';
 
// Return if the text is already lower than the cutoff
if (text.length < length) return text;
 
// Otherwise, check if the last character is a space.
// If not, keep counting down from the last character
// until we find a character that is a space
for (var i = length-1; text.charAt(i) != ' '; i--) {
length--;
}
 
// The for() loop ends when it finds a space, and the length var
// has been updated so it doesn't cut in the middle of a word.
return text.substr(0, length) + ellipsis;
}


