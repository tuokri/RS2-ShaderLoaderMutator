class ShaderLoaderMutator extends ROMutator
    config(Mutator_ShaderLoader);

var MaterialInstanceConstant TestMaterial;

var Object DummyObject;

function ROMutate(string MutateString, PlayerController Sender, out string ResultMsg)
{
    local array<string> Args;
    local string Command;
    local int MatIndex;
    local string ObjectName;
    local Object LoadedObject;
    local Object FoundObject;
    local Actor TracedActor;
    local StaticMeshActor SMA;
    local vector HitLoc, HitNorm, Start, End;
    local rotator StartRot;

    Args = SplitString(MutateString, " ", True);
    Command = Locs(Args[0]);

    `log("DummyObject:" @ DummyObject);

    `log("MutateString: " @ MutateString);
    `log("Sender: " @ Sender);
    `log("Command: " @ Command);

    switch(Command)
    {
        case "setmaterial":
            MatIndex = int(Args[1]);
            `log("MatIndex: " @ MatIndex);

            Sender.GetPlayerViewPoint(Start, StartRot);
            End = Start + vector(StartRot) * 10000;

            `log("Trace Start:" @ Start);
            `log("Trace End:" @ End);

            TracedActor = Sender.Trace(HitLoc, HitNorm, End, Start, True);
            DrawDebugLine(Start, HitLoc, 255, 10, 10);

            `log("TracedActor:" @ TracedActor);

            if (TracedActor != None)
            {
                SMA = StaticMeshActor(TracedActor);

                `log("SMA:" @ SMA);

                if (SMA != None)
                {
                    `log("SetMaterial()" @ MatIndex @ TestMaterial);
                    SMA.StaticMeshComponent.SetMaterial(MatIndex, TestMaterial);
                }
            }
            break;

        case "findobject":
            ObjectName = Args[1];
            `log("ObjectName:" @ ObjectName);

            LoadedObject = DynamicLoadObject(ObjectName, class'Object', True);
            FoundObject = FindObject(ObjectName, class'Object');
            `log("LoadedObject:" @ LoadedObject);
            `log("FoundObject:" @ FoundObject);
            break;
    }

    super.ROMutate(MutateString, Sender, ResultMsg);
}

DefaultProperties
{
    // Doesn't matter what this points to, as long as it's an object that exists in some package.
    // This will get overwritten by UE3ShaderCachePatcher and set to refer to
    // ShaderCache'ShaderLoader.SeekFreeShaderCache'.
    DummyObject=MaterialInstanceConstant'M_SLM_Test.Materials.M_CustomTest_INST'

    // MIC with a custom master material as a parent. Trying to use this without
    // patching DummyObject will fail in game.
    TestMaterial=MaterialInstanceConstant'M_SLM_Test.Materials.M_CustomTest_INST'
}
