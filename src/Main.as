// c 2023-12-26
// m 2023-12-28

bool abort = false;
CGamePlaygroundUIConfig::EUISequence desiredSequence;
bool inMap = false;
bool switching = false;
string title = Icons::Film + " Sequences";

void RenderMenu() {
    if (UI::BeginMenu(title, inMap)) {
        UI::MenuItem("\\$3F3" + Icons::Play + "\\$AAA Current: \\$G" + GetSequence(), "", false, false);

        if (UI::MenuItem("\\$F33" + Icons::Times + "\\$G Abort"))
            abort = true;

        for (uint i = 0; i < 12; i++) {
            CGamePlaygroundUIConfig::EUISequence seq = CGamePlaygroundUIConfig::EUISequence(i);
            if (UI::MenuItem("\\$36D" + Icons::Film + "\\$G " + tostring(seq))) {
                desiredSequence = seq;
                startnew(SetSequence);
            }
        }

        UI::EndMenu();
    }
}

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        inMap = App.RootMap !is null;
        yield();
    }
}

string GetSequence() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (Playground is null)
        return "null";

    if (Playground.UIConfigs.Length < 1)
        return "null";

    return tostring(Playground.UIConfigs[0].UISequence);
}

void SetSequence() {
    if (switching)
        return;

    switching = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaRulesMode@ Script = cast<CSmArenaRulesMode@>(App.PlaygroundScript);
    if (Script is null)
        return;

    CGamePlaygroundUIConfigMgrScript@ Manager = Script.UIManager;
    if (Manager is null)
        return;

    CGamePlaygroundUIConfig@ Config = Manager.UIAll;
    if (Config is null)
        return;

    CGamePlaygroundUIConfig::EUISequence Sequence = Config.UISequence;
    Config.UISequence = desiredSequence;

    while (!Config.UISequenceIsCompleted) {
        if (abort) {
            abort = false;
            break;
        }

        yield();
    }

    Config.UISequence = Sequence;

    switching = false;
}