
default: create.sql

styleguide.xml:
	wget https://raw.githubusercontent.com/meanphil/bjcp-guidelines-2015/master/styleguide.xml

create.sql: styleguide.xml create-glossary-pages.xsl
	xsltproc create-glossary-pages.xsl styleguide.xml > create.sql

create: create.sql
	mysql wordpress < create.sql

remove.sql:
	echo 'DELETE FROM `wp_posts` WHERE post_content LIKE "<!-- auto-generated bjcp glossary post-->%";' > remove.sql

remove: remove.sql
	mysql wordpress < remove.sql

clean:
	rm -f remove.sql create.sql styleguide.xml

