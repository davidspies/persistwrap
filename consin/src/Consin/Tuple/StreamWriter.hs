{-# LANGUAGE TypeInType #-}

module Consin.Tuple.StreamWriter
    ( StreamWriterT
    , execStreamWriterT
    , runStreamWriterT
    , tell
    , tellX
    ) where

import Conkin (Tuple(..))
import Control.Monad.State (StateT, runStateT)
import qualified Control.Monad.State as State
import Control.Monad.Trans (MonadTrans)
import Data.Function.Pointless ((.:))
import Data.Singletons (Sing)
import Data.Singletons.Decide
import Data.Singletons.Prelude (SList, Sing(SCons, SNil))
import GHC.Stack (HasCallStack)

data BoxBuilder xs f = forall xs'. BoxBuilder (SList xs') (Tuple xs' f -> Tuple xs f)

newtype StreamWriterT xs f m x = StreamWriterT (StateT (BoxBuilder xs f) m x)
  deriving (Functor, Applicative, Monad, MonadTrans)

tell :: (HasCallStack, Monad m) => (forall x . Sing x -> m (f x)) -> StreamWriterT xs f m ()
tell act = StreamWriterT $ do
  BoxBuilder xs constructor <- State.get
  case xs of
    SNil           -> error "Tuple already full"
    x' `SCons` xs' -> do
      v <- State.lift $ act x'
      State.put $ BoxBuilder xs' (constructor . (v `Cons`))

tellX :: (HasCallStack, Monad m, SDecide k) => Sing (x :: k) -> f x -> StreamWriterT xs f m ()
tellX s1 x = tell $ \s2 -> case s1 %~ s2 of
  Proved Refl -> return x
  Disproved{} -> error "Unexpected type"

runStreamWriterT
  :: (HasCallStack, Monad m) => StreamWriterT xs f m x -> SList xs -> m (x, Tuple xs f)
runStreamWriterT (StreamWriterT act) sxs = runStateT act (BoxBuilder sxs id) >>= \case
  (res, BoxBuilder srem fn) -> case srem of
    SNil        -> return (res, fn Nil)
    _ `SCons` _ -> error "Some elements unfilled"

execStreamWriterT :: (HasCallStack, Monad m) => StreamWriterT xs f m x -> SList xs -> m (Tuple xs f)
execStreamWriterT = fmap snd .: runStreamWriterT
