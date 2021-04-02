<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="handle">
            <xsl:value-of select="substring-after($href, 'handle/')"/>
        </xsl:variable>
        <!-- handle: <xsl:value-of select="$handle"/> -->
        <xsl:variable name="externalMetadataURL"> <br />
            <xsl:text>cocoon://metadata/handle/</xsl:text>
            <xsl:value-of select="$handle"/>
            <xsl:text>/mets.xml</xsl:text>
            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
            <!-- <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text> -->
            <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
            <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
            </xsl:if>-->
        </xsl:variable>
        <!-- itemSummaryList-DIM external url: <xsl:value-of select="$externalMetadataURL"/> <br /> -->

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="item-wrapper row">
                    <div class="col-sm-3 hidden-xs">
                        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                            <xsl:with-param name="href" select="$href"/>
                            <xsl:with-param name="externalMetadataURL">
                                <xsl:value-of select="$externalMetadataURL"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </div>

                    <div class="col-sm-9">
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                             mode="itemSummaryList-DIM-metadata">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <h4 class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </h4>
            <div class="artifact-info">
                <span class="author h4">
                    <small>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    </small>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
	                <span class="publisher-date h4">  <small>
	                    <xsl:text>(</xsl:text>
	                    <xsl:if test="dim:field[@element='publisher']">
	                        <span class="publisher">
	                            <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
	                        </span>
	                        <xsl:text>, </xsl:text>
	                    </xsl:if>
	                    <span class="date">
	                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
	                    </span>
	                    <xsl:text>)</xsl:text>
                        </small></span>
                </xsl:if>
            </div>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>

        <xsl:param name="externalMetadataURL"/>
        <!-- mets:fileSec external url: <xsl:value-of select="$externalMetadataURL"/> <br /> -->
        <xsl:variable name="handle">
            <xsl:value-of select="substring-after($href, 'handle/')"/>
        </xsl:variable>
        <!-- mets:fileSec handle: <xsl:value-of select="$handle"/> <br /> -->

        <xsl:variable name="context" select="document($externalMetadataURL)"/>

        <div class="thumbnail artifact-preview">

            <xsl:variable name="primaryBitstream" select="$context/mets:METS/mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
            <!-- mets:fileSec primaryBitstream: <xsl:value-of select="$primaryBitstream"/> <br /> -->

            <xsl:variable name="title">
                <xsl:for-each select="$context/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']">
                    <xsl:if test="../@ID = $primaryBitstream">
                        <xsl:value-of select="./@xlink:title"/><xsl:text>|</xsl:text><xsl:value-of select="substring-before(./@xlink:href,'?')"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <a class="image-link" href="{$href}">
                <xsl:choose>
                    <xsl:when test="contains($title,'.3g2') or contains($title,'.3gp') or contains($title,'.asf') or contains($title,'.avi') or contains($title,'.drc') or contains($title,'.flv') or contains($title,'.m4v') or contains($title,'.mkv') or contains($title,'.mng') or contains($title,'.mov') or contains($title,'.qt') or contains($title,'.mp4') or contains($title,'.m4p') or contains($title,'.m4v') or contains($title,'.mp2') or contains($title,'.mpe') or contains($title,'.mpv') or contains($title,'.mpg') or contains($title,'.mpeg') or contains($title,'.m2v') or contains($title,'.mxf') or contains($title,'.nsv') or contains($title,'.ogg') or contains($title,'.ogv') or contains($title,'.rm') or contains($title,'.rmvb') or contains($title,'.roq') or contains($title,'.svi') or contains($title,'.vob') or contains($title,'.webm') or contains($title,'.wmv') or contains($title,'.yuv')">
                        <xsl:variable name="src">
                            <xsl:value-of select="substring-after($title,'|')"/>
                        </xsl:variable>

                        <xsl:variable name="subtitles">
                            <xsl:for-each select="$context/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']">
                                <xsl:if test="contains(./@xlink:title, '.vtt')">
                                    <xsl:value-of select="substring-before(./@xlink:href,'?')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>

                        <xsl:variable name="temp-label">
                            <xsl:value-of select="substring-before($subtitles, '.')"/>
                        </xsl:variable>

                        <xsl:variable name="label">
                            <xsl:call-template name="substring-after-last">
                                <xsl:with-param name="string" select="$temp-label" />
                                <xsl:with-param name="delimiter" select="'_'" />
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($title,'.3g2') or contains($title,'.3gp') or contains($title,'.asf') or contains($title,'.avi') or contains($title,'.m4v') or contains($title,'.mov') or contains($title,'.qt') or contains($title,'.mp4') or contains($title,'.m4p') or contains($title,'.m4v') or contains($title,'.mpg') or contains($title,'.mpeg') or contains($title,'.m2v') or contains($title,'.vob') ">
                                <xsl:variable name="type" select="string('video/mp4')"/>
                                <xsl:call-template name="video">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                    <xsl:with-param name="subtitles" select="$subtitles"/>
                                    <xsl:with-param name="label" select="$label"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="contains($title,'.ogg') or contains($title,'.ogv')">
                                <xsl:variable name="type" select="string('video/ogg')"/>
                                <xsl:call-template name="video">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                    <xsl:with-param name="subtitles" select="$subtitles"/>
                                    <xsl:with-param name="label" select="$label"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="contains($title,'.webm')">
                                <xsl:variable name="type" select="string('video/webm')"/>
                                <xsl:call-template name="video">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                    <xsl:with-param name="subtitles" select="$subtitles"/>
                                    <xsl:with-param name="label" select="$label"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="contains($title,'.act') or contains($title,'.aiff') or contains($title,'.aac') or contains($title,'.amr') or contains($title,'.ape') or contains($title,'.au') or contains($title,'.awb') or contains($title,'.dct') or contains($title,'.dss') or contains($title,'.dvf') or contains($title,'.flac') or contains($title,'.gsm') or contains($title,'.iklax') or contains($title,'.ivs') or contains($title,'.m4a') or contains($title,'.mmf') or contains($title,'.mp3') or contains($title,'.mpc') or contains($title,'.msv') or contains($title,'.oga') or contains($title,'.opus') or contains($title,'.ra') or contains($title,'.raw') or contains($title,'.sln') or contains($title,'.tta') or contains($title,'.vox') or contains($title,'.wav') or contains($title,'.wave') or contains($title,'.wma') or contains($title,'.wv') or contains($title,'.weba')">
                        <xsl:variable name="src">
                            <xsl:value-of select="substring-after($title,'|')"/>
                        </xsl:variable>

                        <xsl:choose>
                            <xsl:when test="contains($title,'.weba')">
                                <xsl:variable name="type" select="string('audio/webm')"/>
                                <xsl:call-template name="audio">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="contains($title,'.mp3')">
                                <xsl:variable name="type" select="string('audio/mpeg')"/>
                                <xsl:call-template name="audio">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="contains($title,'.oga') or contains($title,'.opus')">
                                <xsl:variable name="type" select="string('audio/ogg')"/>
                                <xsl:call-template name="audio">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="contains($title,'.wav') or contains($title,'.wave')">
                                <xsl:variable name="type" select="string('audio/wav')"/>
                                <xsl:call-template name="audio">
                                    <xsl:with-param name="src" select="$src"/>
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$context/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[1]/@GROUPID">

                    <!-- Checking if Thumbnail is restricted and if so, show a restricted image -->
                        <xsl:variable name="src">
                            <xsl:value-of select="$context/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[1]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($src,'isAllowed=n')">
                                <div style="width: 100%; text-align: center">
                                    <i aria-hidden="true" class="glyphicon  glyphicon-lock"></i>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-responsive img-thumbnail" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$src"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <img class="img-thumbnail" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="data-src">
                                <xsl:text>holder.js/100%x</xsl:text>
                                <xsl:value-of select="$thumbnail.maxheight"/>
                                <xsl:text>/text:No Thumbnail</xsl:text>
                            </xsl:attribute>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </div>
    </xsl:template>




    <!--
        Rendering of a list of items (e.g. in a search or
        browse results page)

        Author: art.lowel at atmire.com
        Author: lieven.droogmans at atmire.com
        Author: ben at atmire.com
        Author: Alexey Maslov

    -->



        <!-- Generate the info about the item from the metadata section -->
        <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
            <xsl:variable name="itemWithdrawn" select="@withdrawn" />
            <div class="artifact-description">
                <div class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$itemWithdrawn">
                                    <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </div>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
                <div class="artifact-info">
                    <span class="author">
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                    <span>
                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </span>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='creator']">
                                <xsl:for-each select="dim:field[@element='creator']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor']">
                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                        <span class="publisher-date">
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dim:field[@element='publisher']">
                                <span class="publisher">
                                    <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </span>
                    </xsl:if>
                </div>
            </div>
        </xsl:template>

</xsl:stylesheet>
