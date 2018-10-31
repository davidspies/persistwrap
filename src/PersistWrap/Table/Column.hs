{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UndecidableInstances #-}

module PersistWrap.Table.Column where

import Data.Singletons.Prelude
import Data.Singletons.TH
    (singDecideInstances, singEqInstances, singOrdInstances, singletons, singletonsOnly)
import Data.Singletons.TypeLits (Symbol)

import PersistWrap.Structure (PrimName)

$(singletons [d|
  data BaseColumn text = Prim PrimName | Enum text [text] | ForeignKey text | JSON
  data Column text = Column Bool (BaseColumn text)
  data Schema text = Schema text [(text,Column text)]
  |])

$(singDecideInstances [''BaseColumn, ''Column, ''Schema])
$(singEqInstances [''BaseColumn, ''Column, ''Schema])
$(singOrdInstances [''BaseColumn, ''Column, ''Schema])

$(singletonsOnly [d|
  schemaCols :: Schema Symbol -> [(Symbol, Column Symbol)]
  schemaCols (Schema _ cs) = cs
  schemaName :: Schema Symbol -> Symbol
  schemaName (Schema n _) = n
  |])

type TabSchema (tab :: (*,Schema Symbol)) = Snd tab
type TabName tab = SchemaName (TabSchema tab)
type TabCols tab = SchemaCols (TabSchema tab)
