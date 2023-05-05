{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (filterM)
import Control.Monad.IO.Class (liftIO, MonadIO)

import qualified GHC as Ghc
import qualified GHC.Paths as Ghc
import qualified GHC.Unit.Types as Ghc
import qualified GHC.Utils.Outputable as Ghc

guessTarget :: Ghc.GhcMonad m => String -> m Ghc.Target
guessTarget t = Ghc.guessTarget t Nothing Nothing

print' :: (MonadIO m, Ghc.Outputable a) => m a -> m ()
print' action = do
  res <- action
  liftIO $ putStrLn (Ghc.showPprUnsafe res)

getLoadedModSummaries :: Ghc.GhcMonad m => m [Ghc.ModSummary]
getLoadedModSummaries = do
  modGraph <- Ghc.getModuleGraph
  let modSummaries = Ghc.mgModSummaries modGraph
  filterM (Ghc.isLoaded . Ghc.ms_mod_name) modSummaries

mkModule :: Ghc.GhcMonad m => String -> m (Ghc.GenModule Ghc.UnitId)
mkModule nm = do
    df <- Ghc.getSessionDynFlags
    pure $ Ghc.mkModule (Ghc.homeUnitId_ df) (Ghc.mkModuleName nm)

main :: IO ()
main = do
  Ghc.runGhc (Just Ghc.libdir) $ do
    Ghc.setSessionDynFlags =<< Ghc.getSessionDynFlags

    print' getLoadedModSummaries
    fooTarget <- guessTarget "Foo.hs"
    Ghc.addTarget fooTarget
    m <- mkModule "Foo"
    print' $ Ghc.load (Ghc.LoadDependenciesOf m)
    print' getLoadedModSummaries
