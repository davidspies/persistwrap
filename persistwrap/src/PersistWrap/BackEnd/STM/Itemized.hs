{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE UndecidableInstances #-}

module PersistWrap.BackEnd.STM.Itemized
    ( withEmptyTablesItemized
    ) where

import Control.Monad.IO.Class (MonadIO)

import Conkin.Extra (Always)
import PersistWrap.Itemized (Itemized)
import PersistWrap.BackEnd.Helper (AllEmbed, Items, setupHelper)
import PersistWrap.Table.BackEnd.STM.Internal (STMPersist, unsafeSetupEmptyTables)
import PersistWrap.Table (ForeignKey)

withEmptyTablesItemized
  :: forall fnitems m x
   . (MonadIO m, Always AllEmbed fnitems)
  => (forall s . Itemized (Items (fnitems (ForeignKey (STMPersist s m)))) (STMPersist s m) x)
  -> m x
withEmptyTablesItemized =
  setupHelper @fnitems (\schs act -> unsafeSetupEmptyTables schs (const act))
