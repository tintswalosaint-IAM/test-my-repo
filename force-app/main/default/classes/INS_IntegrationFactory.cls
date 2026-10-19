public class INS_IntegrationFactory {
    public static INS_IIntegrationHandler getHandler(String targetSystem) {
        if (targetSystem == 'DOTSURE') {
            return new INS_DotsureIntegrationHandler();
        }

        return null;
    }
}