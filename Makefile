
default: create.sql

styleguide-old.xml:
	curl --output styleguide-old.xml https://raw.githubusercontent.com/meanphil/bjcp-guidelines-2015/master/styleguide.xml

create-old.sql: styleguide-old.xml create-pages-old.xsl
	xsltproc create-pages-old.xsl styleguide-old.xml > create-old.sql

create-old: create-old.sql
	mysql wordpress < create-old.sql

styleguide.xml:
	curl --output styleguide.xml https://bjcp.hbcon-test.de/styleguide/bjcp-2015-styleguide-de.xml

create.sql: styleguide.xml create-pages.xsl
	xsltproc create-pages.xsl styleguide.xml > create.sql

create: create.sql
	mysql wordpress < create.sql

remove.sql:
	echo 'DELETE FROM `wp_posts` WHERE post_content LIKE "<!-- auto-generated bjcp post -->%";' > remove.sql

remove: remove.sql
	mysql wordpress < remove.sql

clean:
	rm -f remove.sql create.sql styleguide.xml create-old.xsl styleguide-old.xml

