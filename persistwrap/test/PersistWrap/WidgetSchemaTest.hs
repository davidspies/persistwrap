module PersistWrap.WidgetSchemaTest
    ( test_widget_schemas
    ) where

import qualified Data.ByteString.Lazy.Char8 as BS
import Data.Proxy (Proxy)
import Text.Show.Pretty (ppShow)

import PersistWrap.Persistable
import PersistWrap.Structure
import Test.Tasty (TestTree)
import Test.Tasty.Golden (goldenVsString)
import PersistWrap.TestUtils.Widget

test_widget_schemas :: TestTree
test_widget_schemas =
  goldenVsString "test_widget_schemas" "test/goldens/widget_schemas.golden"
    $ return
    $ BS.pack
    $ ppShow
    $ entitySchemas @"widget" @(StructureOf (Widget Proxy))
