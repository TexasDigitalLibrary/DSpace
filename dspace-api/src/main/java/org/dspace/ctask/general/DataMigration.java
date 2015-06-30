/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask.general;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.Bundle;
import org.dspace.content.Bitstream;
import org.dspace.content.DSpaceObject;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;

/* TODO: Create curation task to purge files marked for deletion */

/**
 * DataMigration is a task that migrate bitstreams from different asset stores to dspace's currently asset store.
 *
 * @author arturoklie
 */
@Distributive
public class DataMigration extends AbstractCurationTask
{
    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws IOException
     */

    /** log4j logger */
    private static final Logger log = Logger.getLogger(Bitstream.class);

    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        distribute(dso);
        return Curator.CURATE_SUCCESS;
    }
    
    @Override
    protected void performItem(Item item) throws SQLException, IOException 
    {
        
        for ( Bundle bundle : item.getBundles() )
        {
            for ( Bitstream bitstream : bundle.getBitstreams() )
            {   
                // Get the current asset store location used by dspace (defined in dspace.cfg). Set to default (0) if not found.
                int dspaceStoreNumber = ConfigurationManager.getIntProperty("assetstore.incoming");

                // Only migrate bitstreams that are not stored in the current dspace asset store location and have not been marked for deletion.
                if ( bitstream.getStoreNumber() != dspaceStoreNumber && bitstream.isDeleted() != true ) {

                    Bitstream newBitstream = null;

                    // Create new bitstream object in the current dspace asset store location.
                    try{
                        newBitstream = bundle.createBitstream( bitstream.retrieve() );    
                    }
                    catch ( AuthorizeException ae ) {
                        // TODO: Surface authorization error to the UI so the user can become aware.
                        log.error("Authorization error while attempting to create bitstream from ID "+bitstream.getID()+". ", ae);
                    }

                    if ( newBitstream != null ) {
                    
                        // Set Format
                        newBitstream.setFormat( bitstream.getFormat() );

                        // Set User Format Description
                        newBitstream.setUserFormatDescription( bitstream.getUserFormatDescription() );

                        // Set Name
                        newBitstream.setName( bitstream.getName() );

                        // Set Description
                        newBitstream.setDescription( bitstream.getDescription() );

                        // Set Sequence ID
                        newBitstream.setSequenceID( bitstream.getSequenceID() );

                        // Set Source
                        newBitstream.setSource( bitstream.getSource() );

                        // Update bitstream with metadata changes
                        try{
                            newBitstream.update();
                        }
                        catch ( AuthorizeException ae ) {
                            // TODO: Surface authorization error to the UI so the user can become aware.
                            log.error("Authorization error while attempting to update bitstream from ID "+bitstream.getID()+". ", ae);
                        }

                        /* Register bitstream in the database.
                        try{
                            bundle.registerBitstream( bitstream.getStoreNumber(), bitstream.getSource() );
                        }
                        catch ( AuthorizeException ae ) {
                            // TODO: Surface authorization error to the UI so the user can become aware.
                            log.error("Authorization error while attempting to register bitstream with ID "+bitstream.getID()+". ", ae);
                        }*/

                        // Mark old bitsream for deletion.
                        try{
                            bundle.removeBitstream( bitstream );
                        }
                        catch ( AuthorizeException ae ) {
                            // TODO: Surface authorization error to the UI so the user can become aware.
                            log.error("Authorization error while attempting to delete bitstream with ID "+bitstream.getID()+". ", ae);
                        }
                    } else {
                    // Do nothing if the new bitstream failed to instantiate.
                    }

                } else {
                    // Do nothing if the bitstream is already in the current dspace asset store location.
                }
            }           
        }
    }
}
