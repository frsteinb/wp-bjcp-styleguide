# wp-bjcp-styleguide

## An XML-based approach to create WordPress posts for all BJCP styles.

This is no more than a very simple Makefile and an XSL stylesheet. The
idea is to download an XML representation of the styleguild and transform
it to a sequence of MySQL commands that can be applied to a WordPress
database to create/update the posts.

The stats blocks will contain international units primarily converted
to German units (Stammwürze in °P, Color in EBC), but the original
value are also displayed.

### Prerequisite

The posts are generated as glossary entries. Therefore, the glossary
plugin "CM Tooltip Glossary" has to be installed and activated.

### IMPORTANT NOTE

The BJCP does a hard voluntary job. Please accept there terms
on using the style guidelines. 

### License

See [LICENSE.txt][1]

[1]: LICENSE.txt


