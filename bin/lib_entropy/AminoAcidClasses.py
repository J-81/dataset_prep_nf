# class key as follows:
# a - aliphatic, r - aromatic, p - polar
# t - postive, n - negative, s - special

# handles U -> C -> a
# B -> D -> n
# J -> L -> a
# Z -> E -> n
E6 = {
 'A': 'a',
 'V': 'a',
 'L': 'a',
 'I': 'a',
 'M': 'a',
 'C': 'a',
 'F': 'r',
 'W': 'r',
 'Y': 'r',
 'H': 'r',
 'S': 'p',
 'T': 'p',
 'N': 'p',
 'Q': 'p',
 'K': 't',
 'R': 't',
 'D': 'n',
 'E': 'n',
 'G': 's',
 'P': 's',
 'U': 'a',
 'B': 'n',
 'J': 'a',
 'Z': 'n'
 }

# includes handling for U -> C
# B -> D
# J -> L
# Z -> E
E20 = {'A': 'A',
 'V': 'V',
 'L': 'L',
 'I': 'I',
 'M': 'M',
 'C': 'C',
 'F': 'F',
 'W': 'W',
 'Y': 'Y',
 'H': 'H',
 'S': 'S',
 'T': 'T',
 'N': 'N',
 'Q': 'Q',
 'K': 'K',
 'R': 'R',
 'D': 'D',
 'E': 'E',
 'G': 'G',
 'P': 'P',
 'U': 'C',
 'B': 'D',
 'J': 'L',
 'Z': 'E'
 }
