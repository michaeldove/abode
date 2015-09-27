import re

################################################################################
# Human Command Protocol
################################################################################

class HumanCommandProtocol:
    
    def __init__(self):
        self.commands = (('^help', self.help),)


    def help(self, *args):
        """
        Returns help text, list of lines..
        """
        return ['describe controls']

    def parse(self, text):
        """
        Parse text and execute appropriate command.
        """
        for (pattern, handler) in self.commands:
            match = re.search(pattern, text)
            if match:
                return handler(text)
        return ('Unknown command',)





