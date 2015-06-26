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
import java.util.HashMap;
import java.util.Map;

import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;

/**
 * DataMigration is a task that migrates bitstreams scattered across multiple
 * asset stores to the asset store assigned for writing.
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
        Context context = new Context();
        for (Bundle bundle : item.getBundles())
        {
            for (Bitstream bs : bundle.getBitstreams())
            {
                // If this bitstream's stored location doesn't match the set storage location, then migrate
                if ( bs.getStoreNumber() != 1 ) {
                    
                    // Retrieve the bits from the old bitstream and create a new copy of the bitstream.
                    bs.create( context, bs.retrieve() );

                    // Mark the old bitstream for deletion.
                    bs.delete();
                }
                else {
                    // Do nothing
                }
            }           
        }
        c.complete();
        /* Separate curation task? 
        // Delete bitstream from asset store (needs to happen after 1 hr)
        import org.dspace.storage.bitstore.BitstreamStorageManager;
        deleteDbRecords = true;
        verbose = true;
        cleanup( deleteDbRecords, verbose)*/
    }
}
