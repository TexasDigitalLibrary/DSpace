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

import org.dspace.storage.bitstore.BitstreamStorageManager;
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
                dspaceStoreNumber = ConfigurationManager.getProperty("assetstore.incoming");
                if ( storeNumber == null ) {
                    storeNumber = 0;
                }

                // Only migrate bitstreams that are not stored in the current dspace asset store location and have not been marked for deletion.
                if ( bitstream.getStoreNumber() != dspaceStoreNumber && bitstream.isDeleted != true ) {

                    // Create new bitstream object in the current dspace asset store location, and create new bitstream in DB.
                    Bitstream newBitstream = bundle.createBitstream( bitstream.retrieve() );

                    // Mark old bitsream for deletion.
                    bundle.deleteBitstream( bitstream );

                }
                else {
                    // Do nothing if the bitstream is already in the current dspace asset store location.
                }
            }           
        }
    }
}
