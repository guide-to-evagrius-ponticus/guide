<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tan="tag:textalign.net,2015:ns"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   expand-text="yes" exclude-result-prefixes="#all" version="3.0">
   <xsl:variable name="lemma-keys.eng" select="map:keys($lemmas.eng)"/>
   <xsl:variable name="eng.words.standard" as="xs:string+" select="
         'abandon', 'abide', 'Abner', 'Abraham', 'abstain',
         'abuse', 'accept', 'accident', 'accompany', 'accomplish',
         'accuse', 'accustom', 'achieve', 'achievement',
         'acquaint', 'acquire', 'action', 'activity', 'Adam', 'add',
         'address', 'color', 'abandonment', 'abate', 'Abba', 'ability',
         'able', 'abolition', 'abomination', 'abruptly', 'absence', 'absent',
         'absolute', 'absolutely', 'abstinence', 'absurd', 'abundance', 'abundant',
         'abundantly', 'academy', 'accessible', 'accidental', 'accidentally',
         'accost', 'accountant', 'accurately', 'accuser', 'acedia', 'activate',
         'active', 'actual', 'actually', 'acutely', 'addition', 'additionally',
         'administer', 'administration', 'administrator', 'admirable', 'admiration', 'admire',
         'admissible', 'admit', 'adoption', 'adorable', 'adore', 'adornment', 'adult', 'adultery',
         'adulthood', 'advice', 'affair', 'affect', 'affection', 'afflict',
         'affliction', 'afraid', 'age', 'aggressively', 'agitate', 'agitation', 'agree', 'aground',
         'aim', 'air', 'alarm', 'Alexandria', 'alien', 'alive', 'all-out', 'allegiance',
         'allegorical', 'allegorize', 'allegory', 'allow', 'almighty', 'almost',
         'aloft', 'alone', 'along', 'already', 'altar', 'amaze', 'amber', 'ambush', 'Amen',
         'amend', 'amount', 'Anatolius', 'anchorite', 'ancient', 'anew', 'angel', 'angelic', 'anger',
         'angry', 'animal', 'animate', 'announce', 'annoy', 'anoint', 'ant', 'antagonist', 'anterior',
         'Anthony', 'anticipate', 'antidote', 'anxiety', 'anyone', 'apart',
         'apatheia', 'apathetic', 'apocalypse', 'apostle', 'apostolic',
         'apparent', 'apparition', 'appear', 'appearance', 'appertain',
         'application', 'apply', 'appoint', 'apprehend', 'apprise', 'appropriate', 'approve',
         'archangel', 'archetype', 'architect', 'ardently', 'area', 'argument',
         'aright', 'arise', 'ark', 'armed', 'around', 'arouse', 'arrange', 'arrangement', 'array',
         'arrival', 'arrive', 'arrogant', 'arrow', 'art', 'artisan', 'artist',
         'ascend', 'ascension', 'ascent', 'ascertain', 'ascetic', 'ascetical',
         'asceticism', 'ash', 'Ashtaroth', 'aside', 'ask', 'asleep', 'aspire', 'assail',
         'assault', 'assembly', 'assent', 'assert', 'asset', 'assign', 'assistance', 'assistant',
         'associate', 'assume', 'assumption', 'assurance', 'astonish', 'astound', 'astray', 'Athanasius', 'athlete', 'attach', 'attachment',
         'attain', 'attainment', 'attend', 'attendance',
         'attention', 'attentive', 'attract', 'attribute', 'author', 'authority', 'avarice',
         'avenge', 'averse', 'avoid', 'await', 'awake', 'awaken', 'aware', 'awe', 'awesome',
         'babble', 'back', 'bad', 'badly', 'Balaam', 'balance', 'ball', 'banish', 'banquet', 'baptism',
         'Baptist', 'baptize', 'bar', 'Baraq', 'bare', 'Basil', 'basket', 'battle', 'battle-array',
         'bear', 'beast', 'beat', 'beating', 'beatitude', 'beautiful', 'beauty', 'bee', 'befit', 'befoul', 'beg',
         'beget', 'begin', 'beginning', 'behalf', 'behind', 'behold', 'belief',
         'believe', 'belly', 'belong', 'belt', 'Ben-Sirach', 'bend', 'beneath', 'beneficence', 'beneficent',
         'beneficial', 'beseech', 'beset', 'beside', 'besiege', 'best', 'bestial', 'bestow', 'betray', 'betrayal', 'better',
         'beware', 'bewitch', 'beyond', 'Bible', 'bid', 'bill', 'bind', 'bird', 'birth', 'bishop', 'bite', 
         'bitter', 'bizarre', 'blade', 'blame', 'blamelessly', 'blameworthy', 'blaspheme',
         'blasphemy', 'blend', 'blessedly', 'blissful', 'block', 'blood', 'bloody', 'boat',
         'bodily', 'body', 'boil', 'boldly', 'bond', 'book', 'border', 'borne', 'bother', 'bowl', 'brain',
         'breach', 'bread', 'break', 'breast', 'breath', 'breathe', 'bridegroom', 'bridle', 'brief',
         'briefly', 'brightly', 'bring', 'broken', 'bronze', 'brood', 'brother', 'brow', 'bud', 'build', 'builder',
         'burdensome', 'burst', 'bury', 'bush', 'busy',
         'cabinet', 'call', 'calm', 'calmly', 'camp', 'cancel', 'capable', 'capacity', 'Cappadocian', 'captive',
         'captor', 'capture', 'careful', 'carefully', 'carnal', 'carpenter', 'carpentry',
         'carrion-fly', 'carry', 'case', 'cassia', 'cast', 'catch', 'cater', 'cause', 'cease',
         'ceaselessly', 'celebration', 'celestial', 'cell', 'Cenobia', 'censer', 'century',
         'certain', 'certainly', 'certainty', 'chaff', 'chain', 'chalice', 'chamber',
         'chant', 'chapter', 'character', 'characteristic', 'chariot', 'charity', 'charm', 'chase', 'chaste',
         'chastity', 'check', 'cheer', 'cherish', 'cherub', 'chick', 'child', 'childlike', 'choice', 'choir',
         'choke', 'choleric', 'choose', 'chrism', 'Christ', 'Christian', 'Christianity',
         'church', 'churn', 'circle', 'circumcision', 'circumcize', 'circumscribe', 'circumstance', 'circumvent', 'cistern', 'citizen',
         'citizenship', 'city', 'clad', 'claim', 'class', 'claw', 'clay', 'clean', 'clearly', 'clever',
         'climb', 'cling', 'clock', 'closely', 'clothe', 'cloud', 'co-worker', 'coarse', 'coarsen', 'coat',
         'coessential', 'coexist', 'coextensive', 'cognate', 'coheir', 'coil', 'coin', 'cold', 'colleague', 'collect', 'column', 'comb',
         'combat', 'combatant', 'combination', 'combine', 'comfort', 'command', 'commandment',
         'commence', 'commingle', 'commit', 'common', 'communion', 'compactly', 'companion', 'company', 'compare', 'comparison', 'compassion',
         'compel', 'complain', 'complete', 'completely', 'completion', 'component', 'compose', 'composite', 'composition',
         'comprehend', 'comprehension', 'comprise', 'compulsion', 'compunction', 'conceal', 'conceit', 'conceive',
         'concentrate', 'concentration', 'concept', 'conception', 'concerning', 'concession', 'conclude', 'concupiscible',
         'condemn', 'condemnation', 'condition', 'confess', 'confession', 'confide', 'confidence', 'confine', 'confirm', 'conflict',
         'conform', 'confuse', 'confusion', 'congenitally', 'congestive', 'conjecture', 'conjoin', 'connatural', 'connect',
         'conquer', 'conquest', 'conscience', 'consent', 'consequence', 'consider', 'considerable',
         'consideration', 'consist', 'consistently', 'consolation', 'consort', 'constant',
         'constantly', 'constituent', 'constitute', 'constraint', 'constrict', 'construct', 'consubstantial',
         'consubstantiality', 'consult', 'consume', 'contain', 'contaminate', 'contemplate', 'contemplation',
         'contemplative', 'contemplator', 'contempt', 'content', 'continence', 'continually',
         'continue', 'continuously', 'contradict', 'contradiction', 'contrary', 'contribute',
         'controversy', 'convenient', 'conversation', 'conversational', 'converse', 'conversion', 'convert',
         'convince', 'cool', 'cooperate', 'cooperation', 'copy', 'corner', 'corporeal', 'correct', 'corresponding', 'corruptible', 'corruption', 'country',
         'counsel', 'count', 'courage', 'courageously', 'course', 'covenant', 'cowardly', 'craft', 'crane', 'crash', 'crawl', 'create', 'creation',
         'creator', 'creature', 'creep', 'critical', 'crop', 'crowd', 'crown', 'crucifixion',
         'cruel', 'crush', 'cull', 'cultivate', 'cunningly', 'cup', 'cure', 'current', 'curse', 'Cush',
         'customarily', 'customary', 'cut',
         'damage', 'Damascus', 'dance',
         'danger', 'Daniel', 'dare', 'dark', 'darken', 'darkly', 'dash', 'daughter', 'David', 'day', 
         'day-laborer', 'Day-Star', 'dead', 'deadbolt', 'deaf', 'dear', 'death', 'debtor', 
         'deceit', 'deceitful', 'deceive', 'decent', 'deception', 'deceptive', 'declaratory', 'declare', 
         'decline', 'decorate', 'decrease', 'deed', 'deep', 'deeply', 'deer', 'defend', 
         'defendant', 'deficient', 'defile', 'define', 'definition', 'deflect', 'deformity', 'degree', 'deity', 'delay', 'delectable', 
         'delight', 'deliver', 'deliverance', 'demand', 'demon', 'demonic', 'demonstrate', 
         'demonstration', 'denial', 'denote', 'dense', 'deny', 'depart', 'departure', 'depend', 'dependent', 
         'depict', 'deprecate', 'depressed', 'depressing', 'depression', 'deprivation', 'deprive', 'depth', 'derive', 'descend', 'descent', 'describe', 
         'deserter', 'designate', 'designation', 'desirable', 'despair', 
         'despise', 'despite', 'despondency', 'destroy', 'destroyer', 'destruction', 'destructive', 
         'detail', 'devastate', 'deviation', 'devil', 'devise', 'devote', 'devout', 'dialectic', 'dianoia', 'Didymus', 'die', 
         'diet', 'difference', 'different', 'difficult', 'difficulty', 'dignity', 'diligence', 
         'diligent', 'diminish', 'diminution', 'dinner', 'direct', 'direction', 'directly', 
         'disappearance', 'discard', 'discern', 'discernment', 'discharge', 'disciple', 'disconcert', 'discourage', 'discover', 'discussion', 
         'disdain', 'disease', 'disgorge', 'disgrace', 'disharmony', 'dishearten', 'dislike', 'dismay', 'disobedient', 
         'disorder', 'dispassion', 'dispassionate', 'dispassionately', 'dispensation', 'dispose',
         'disposition', 'dispossessed', 'dispute', 'dissipate', 'dissolution', 'distant', 'distinct', 'distinction', 
         'distinctly', 'distinguish', 'distract', 'distraction', 'disturb', 'disturbance', 'diverse', 
         'diversity', 'divest', 'divide', 'divine', 'divinity', 'doctor', 'doctrine', 'dog', 'dog-like', 
         'doing', 'domestic', 'dominate', 'door', 'dove', 'downtrodden', 'drag', 'dragon', 'draw', 'dread', 'dream', 
         'drink', 'drinking-cup', 'drive', 'drunken', 'dry', 'duality', 'due', 'dumb', 
         'dunk', 'dust', 'dwell', 'dyad', 
         'eager', 'eagerly', 'eagle', 'ear', 'earnest', 'earth', 'earthen', 'earthly', 
         'easily', 'east', 'eat', 'Ecclesiastes', 'economy', 'education', 'educe', 'effort', 'Egypt', 'Egyptian', 
         'eidola', 'eight', 'eighth', 'either', 'elder', 'election', 'element', 'elevate', 'eleventh', 'Elijah', 'eliminate', 
         'embark', 'embrace', 'emerge', 'empire', 'employ', 'empower', 'empty', 'enable', 'enact', 'encounter', 
         'enchain', 'encircle', 'encompass', 'encourage', 'endurance', 'endure', 'enemy', 'energy', 'enflame', 'enfold', 'engage', 'engender', 
         'engrave', 'enjoy', 'enjoyable', 'enlighten', 'enmesh', 'ennoia', 'enough', 'enrich', 'enslave', 'entail',
         'enter', 'entertain', 'entice', 'entire', 'entirely', 'entrust', 'entry', 'ephod', 
         'epilogue', 'epithumetikon', 'epithumia', 'equal', 'equality', 'equally', 'equip', 'equipment', 
         'equivalent', 'erect', 'error', 'Esau', 'escape', 'especially', 'essence', 'essential', 
         'essentially', 'establish', 'esteem', 'eternal', 'eternally', 'ethical', 'Ethiopia', 
         'evade', 'Evagrius', 'Eve', 'eventually', 'ever', 'every', 'everyone', 'everywhere', 'evidence', 
         'evident', 'evil', 'evolution', 'exact', 'exactly', 'exalt', 'exaltation', 'examination', 
         'examine', 'example', 'exasperate', 'excel', 'excellent', 'except', 'excise', 'excite', 'exclude', 'exclusively', 
         'excuse', 'exemption', 'exert', 'exhort', 'exit', 'exist', 'existence', 'existent', 
         'expect', 'expel', 'expert', 'explain', 'explanation', 'explicate', 
         'explication', 'expose', 'exposition', 'express', 'expression', 'extend', 'extensive', 'extent', 'exterior', 
         'exterminate', 'external', 'externally', 'extinct', 'extinguish', 'extract', 
         'extraordinary', 'extremely', 'eye', 'eyesight', 
         'fact', 'fail', 'failure', 'fairly', 'faith', 'false', 
         'falsehood', 'falsely', 'fame', 'family', 'fantasize', 'fantasy', 'far', 'fashion', 'fast', 
         'fasten', 'fat', 'fate', 'father', 'fatherland', 'fault', 'favor', 'favorable', 
         'fearful', 'feel', 'feign', 'fellowship', 'fervently', 'festal', 
         'feverish', 'fiery', 'fifth', 'fifty', 'fifty-three', 'filial', 'fill', 'final', 
         'finally', 'find', 'finger', 'finish', 'fire', 'firm', 'firmament', 'first', 'firstborn', 'fish', 
         'fit', 'five', 'fix', 'fixedly', 'flame', 'flatter', 'flavor', 'flea', 'flee', 'flesh', 'flight', 
         'flog', 'flow', 'flower', 'flux', 'focus', 'fog', 'fold', 'follow', 'folly', 'food', 'fool', 'foolish', 
         'foolishly', 'foot', 'forbear', 'forbearance', 'forbid', 'forbidden', 'forcibly', 'foreign', 
         'foreigner', 'foreknowledge', 'foresight', 'forevermore', 'forget', 'forgetful', 'forgive', 
         'formation', 'former', 'formerly', 'fornication', 'forth', 
         'forty', 'foul', 'fount', 'fountain', 'four', 'fourth', 'fragrance', 'fragrant', 
         'frankincense', 'free', 'freedom', 'frequent', 'frequently', 'fresh', 'Friday', 'friend', 
         'friendship', 'frighten', 'fro', 'front', 'fruit', 'fruitful', 'frustrate', 'fugitive', 'fulfill', 
         'full', 'fully', 'function', 'furthermore', 'fury', 
         'Gabriel', 'gain', 'garment', 'gate', 'gather', 'gaze', 'generally', 'generation', 'generic', 'gentle', 'gently', 
         'genuine', 'geography', 'ghost', 'Gideon', 'gift', 'Gihon', 'give', 'giver', 
         'glad', 'glean', 'glimpse', 'gloom', 'gloomy', 'glorify', 'glory', 'gluttony', 'gnash', 'gnostic', 
         'gnostike', 'go', 'goal', 'god', 'godhead', 'godly', 'gold', 'gone', 'good', 
         'goodwill', 'gospel', 'government', 'governor', 'grace', 'gradually', 'grain', 'grand', 
         'grant', 'grape', 'grasp', 'grave', 'great', 'greatly', 'Greek', 'greet', 'Gregory', 'grey', 
         'grief', 'grim', 'ground', 'group', 'grow', 'growth', 'guard', 'guardianship', 
         'guide', 'guilty', 
         'habitation', 'habitual', 'habitually', 'hair', 'hallow', 'hallucination', 'hang', 'haply', 'happen', 'harbor', 
         'hard', 'hardly', 'harm', 'harmful', 'harmoniously', 'harmony', 'harp', 'harvest', 'hasten', 'hate', 
         'haughty', 'haven', 'head', 'headship', 'heal', 'health', 'healthy', 'heap', 'hear', 'hearer', 
         'heart', 'heat', 'heathen', 'heaven', 'heavenly', 'heavenward', 'heavy', 'Hebrew', 'heed',
         'hegemonikon', 'height', 'heir', 'hell', 'helmet', 'henceforth', 'herald', 'hereafter', 
         'heretic', 'heritage', 'hermit', 'hermitage', 'hero', 'hew', 'hexad', 'hexagonal', 'hide', 'high', 
         'highly', 'hind', 'hinder', 'hindrance', 'hold', 'holy', 'home', 'honey', 'honeycomb', 'honor', 
         'honorable', 'hood', 'hook', 'hope', 'Horeb', 'horrible', 'hospitable', 'hospitality', 
         'host', 'hostile', 'hot', 'hour', 'house', 'however', 'human', 'humble', 'humiliate', 
         'humiliation', 'humility', 'hundredfold', 'hunger', 'hungry', 'hunt', 'hurl', 'hurry', 'hurt', 'hymn', 
         'hypocrisy', 
         'ice', 'idea', 'identity', 'idly', 'idol', 'idolatry', 'ignorance', 'ignorant', 'ill', 
         'illuminate', 'image', 'imagine', 'imitate', 'imitation', 'immaterial', 'immaterially', 
         'immeasurable', 'immediately', 'immoderate', 'immoderation', 'immorality', 'immortal', 
         'immortality', 'impartial', 'impassible', 'impede', 'impediment', 'impel', 'imperfect', 
         'impiety', 'impiously', 'implant', 'implicitly', 'implore', 'impossible', 'impotent', 
         'impression', 'imprison', 'improper', 'improperly', 'imprudent', 'impure', 
         'impurity', 'inaccessible', 'inappropriate', 'inasmuch', 'incapable', 'incarnate', 
         'incarnation', 'incense', 'incident', 'incite', 'inclination', 'incline', 'incomprehensibility', 
         'incomprehensible', 'inconceivable', 'incorporeal', 'incorruptibility', 'incorruptible', 
         'independently', 'indescribable', 'indestructible', 'indicate', 'indict', 
         'indifferent', 'indignant', 'indignation', 'indirectly', 'individual', 'indivisibly', 
         'induce', 'indulge', 'ineffable', 'infallible', 'infant', 'infect', 'inferior', 'infiltrate', 'infinite', 'infirmity', 
         'inflammation', 'inflexible', 'influence', 'inform', 'information', 'inherent', 'inherit', 
         'inheritance', 'initiator', 'injure', 'injury', 'ink', 'inn', 'innate', 'inner', 
         'innermost', 'innocence', 'inordinate', 'inrush', 'insane', 'insanity', 'insatiability', 
         'insatiable', 'insensibility', 'insensible', 'insensitivity', 'inseparable', 'inseparably', 
         'inside', 'insight', 'insignificant', 'insinuate', 'insist', 'insofar', 'inspection', 'install', 'instance', 
         'instantly', 'instead', 'instill', 'instruct', 'instruction', 'instrument', 'insult', 
         'insusceptible', 'intellect', 'intellection', 'intellectual', 'intelligence', 
         'intelligent', 'intelligible', 'intemperance', 'intemperate', 'intend', 'intense', 
         'intensification', 'intent', 'intention', 'intently', 'intercession', 'intercourse', 'interest', 
         'interior', 'intermediary', 'intermediate', 'internal', 'interpose', 'interposition', 'interpret', 
         'interpretation', 'interrogate', 'interrupt', 'intimate', 'introduce', 'invalid', 'invasion', 'invent', 'investigate', 
         'investigation', 'investigative', 'investigatively', 'invisibly', 'invite', 'invocation', 
         'involuntarily', 'involve', 'inwardly', 'irascibility', 'irascible', 'iron', 'irrational', 
         'irrationally', 'irregularity', 'irreproachable', 'irritate', 'irritation', 'Isaiah', 
         'isapatheia', 'island', 'Israel', 'issue', 'item', 
         'Jacob', 'jealousy', 'Jericho', 'Jerusalem', 'Jew', 'John', 'join', 'Jordan', 'Joshua', 
         'joy', 'joyful', 'Judah', 'judge', 'judgment', 'justice', 'justifiable', 'justly', 
         'Kaiphas', 'keep', 'ken', 'key', 'kill', 'kind', 'kindle', 'kingdom', 'kithara', 'knife', 'knock', 
         'know', 'knowable', 'knower', 'knoweth', 'knowledge', 'koukoullion', 
         'Laban', 'lack', 'ladder', 'laid', 'lake', 'lamb', 'lamentation', 'lamp', 'land', 
         'language', 'large', 'lash', 'late', 'latter', 'laudably', 'laugh', 'laughing-stock', 'laughter', 
         'law', 'lawful', 'lawlessly', 'lawsuit', 'lay', 'leader', 'Leah', 'lean', 'leap', 
         'learn', 'leave', 'lend', 'length', 'lesson', 'lest', 'let', 'letter', 'Levite', 'lewd', 
         'liberate', 'liberty', 'lie', 'life', 'lifestyle', 'lifetime', 'lift', 
         'likewise', 'limited', 'linen', 'linger', 'link', 'lion', 'lip', 'listen', 'listener', 'literal', 'little', 
         'live', 'liver', 'lobe', 'localize', 'locally', 'lodge',
         'logistikon', 'loin', 'long', 'look', 'loquacity', 'lord', 'lose', 'lost', 
         'lot', 'louse', 'lovable', 'lover', 'low', 'Lucifer', 'luminary', 'luminously', 'lung',
         'lust', 'luxury', 
         'mad', 'magnesium', 'make', 'maker', 'malevolent', 'malice', 'malign', 'malignant', 'man', 
         'manage', 'maneuver', 'manger', 'manifest', 'manifold', 'manipulate', 'mankind', 'manner', 'Manoah', 
         'mantle', 'manual', 'many', 'mar', 'Maria', 'marital', 'mark', 'marvel', 'Mary', 'master', 'mastery', 
         'mat', 'material', 'matter', 'meantime', 'meanwhile', 
         'meat', 'mediation', 'medicine', 'meditate', 'meditation', 'medium', 'meet', 'meeting', 'member', 'memory', 'mental', 
         'merciful', 'mercy', 'mere', 'merely', 'merry', 'metal', 'method', 'middle', 
         'Midian', 'midst', 'mighty', 'milk', 'mind', 'mine', 'mingle', 'minimum', 'ministry', 'miracle', 
         'mirror', 'mischief', 'miserable', 'misfortune', 'mislead', 'mix', 'mixture', 'mob', 'mode', 'model', 'modify', 'moment', 
         'monad', 'monastery', 'money', 'monk', 'month', 'moon', 'moreover', 'morsel', 'mortal', 'mortification', 
         'Moses', 'mosquito', 'mother', 'motion', 'mountain', 'mouth', 'mouthful', 'move', 'movement', 
         'much', 'muddy', 'multiform', 'multiplication', 'multiplicity', 'multiply', 'multitude', 'muscle', 'must', 
         'mute', 'myrrh', 'mystery', 'mystic', 
         'nail', 'nakedly', 'namely', 'nap', 'narrow', 'nation', 'natural', 'naturally', 'nature', 
         'naught', 'nay', 'Nazarene', 'near', 'nearby', 'nearly', 'necessarily', 'necessary', 
         'necessity', 'needful', 'neglect', 'negligence', 'negligent', 'neighbor', 'neither', 
         'nest', 'net', 'neutral', 'never', 'new', 'next', 'night', 'noble', 'nocturnal', 'noema', 'noetic', 
         'noise', 'none', 'nonknower', 'noon', 'noonday', 'normally', 'north', 'northern', 'nose', 
         'note', 'notice', 'notion', 'nourish', 'nourishment', 'nuisance', 'number', 'numerical',
         'nurse', 'nurture',
         'oak', 'oath', 'obey', 'objection', 'oblige', 'obliterate', 'obscure', 'obscurely', 'observation', 
         'observe', 'obstacle', 'obstruct', 'obtain', 'occasion', 'occupation', 'occupy', 'occur', 'odor', 'offence', 'offer', 
         'offshoot', 'often', 'oil', 'old', 'omission', 'omnipotent', 'one', 'oneself', 
         'only-begotten', 'onycha', 'open', 'openly', 'operate', 'operation', 'opinion', 'opponent', 'opportune', 
         'opportunity', 'oppose', 'opposite', 'opposition', 'oppress', 'oppressive', 'ordain', 'orderly', 
         'ordinarily', 'organ', 'organon', 'orient', 'originate', 'orphan', 'otherwise', 'ought', 'outer', 'outrage', 'outside', 
         'overcome', 'overmuch', 'overtake', 'owe',
         'pain', 'painful', 'palace', 'palate', 'palliate', 'pallor', 'paper', 'parable', 'paradise', 
         'paralytic', 'parent', 'part', 'partake', 'partaker', 'partially', 'participate', 
         'particular', 'particularly', 'partly', 'Pascha', 'pass', 'passage', 'passibility', 'passible', 
         'passion', 'passionate', 'passively', 'path', 'patience', 'patient', 'patiently', 
         'patriarch', 'Paul', 'paw', 'pay', 'payment', 'peace', 'pearl', 'peaceful', 'pectoral', 'peculiar', 'peer', 
         'penalty', 'penny', 'pentad', 'Pentecost', 'people', 'perceive', 'perceptible', 
         'perception', 'perchance', 'perfectible', 'perfection', 'perfectly', 'perforate', 'perform', 'perfume', 
         'period', 'perishable', 'permit', 'persecute', 'perseverance', 'persevere', 'person', 
         'persuade', 'persuasive', 'pertain', 'perversion', 'Peter', 'petition', 'phantasm', 'Pharisee', 
         'philian', 'Philistine', 'philosopher', 'philosophize', 'philosophy', 'phrase', 'physician', 
         'physike', 'piece', 'pierce', 'pigeon', 'pinnacle', 'piously', 'plaintiff', 
         'plausible', 'pleasant', 'please', 'pleasure', 'pledge', 'plenty', 'plunder', 'plunge', 'ply', 'point', 
         'pollute', 'pollution', 'ponder', 'poor', 'portion', 'position', 'possess', 'possession', 'possible', 
         'post', 'postpone', 'posture', 'potentially', 'pour', 'poverty', 'power', 'powerful', 'practical', 
         'practice', 'praise', 'praktike', 'praktikos', 'pray', 'prayer', 'preach', 'precede', 'precedence', 
         'precipice', 'precisely', 'predicate', 'predict', 'predominance', 'predominate', 'preeminence', 'preeminent', 
         'prefer', 'preliminary', 'prelude', 'prematurely', 'preparation', 'prepare', 'presence', 
         'presentation', 'preserve', 'preside', 'press', 'pressure', 'presume', 'pretext', 'prevail', 'prevent', 'previously', 
         'prey', 'pride', 'priest', 'priesthood', 'primary', 'primordial', 'principal', 'principality', 
         'principally', 'principle', 'prior', 'prison', 'probably', 'proceed', 'proclaim', 'produce', 'profit', 
         'profitable', 'profound', 'progress', 'progressively', 'prolixity', 'promptly', 'proof', 
         'proper', 'properly', 'property', 'prophecy', 'prophesy', 'prophet', 'propitiate', 'propitiatory', 
         'proportion', 'proportionately', 'propose', 'proposition', 'prostrate', 'protect', 'prototype', 
         'proud', 'prove', 'proverb', 'provide', 'providence', 'provident', 'provoke', 
         'prudence', 'prudent', 'psalm', 'psalmody', 'psychic', 'publican', 'publish', 'pulsate', 
         'punish', 'punishment', 'pure', 'purely', 'purification', 'purify', 'purity', 
         'purpose', 'purse', 'pursue', 'pursuer', 'put', 
         'quality', 'quantifiable', 'quantity', 'quarrelsome', 'quench', 'quest', 'question', 
         'quick', 'quickly', 'quiet', 'quietude', 'quite', 
         'race', 'Rachel', 'radiance', 'radiant', 'rage', 'raise', 'rancor', 'random', 'rank', 'rapidly', 
         'rapture', 'rash', 'rashly', 'rather', 'rational', 'rationality', 'rationally', 'ray', 'reach', 
         'read', 'readily', 'ready', 'real', 'reality', 'really', 'realm', 'reap', 'reasonable', 'rebuke', 
         'recall', 'receive', 'recently', 'reception', 'receptive', 'receptivity', 'recite', 
         'reckon', 'recognize', 'recommend', 'recompense', 'reconcile', 'recount', 'recover', 
         'reduce', 'reestablish', 'refer', 'reference', 'reflect', 'refrain', 'refresh', 'refuge', 'refusal', 
         'refuse', 'regeneration', 'region', 'regret', 'regular', 'rehearse', 'rehearsal', 'reign', 'reject', 
         'rejection', 'rejoice', 'relate', 'relation', 'relationship', 'relative', 'relatively', 
         'relax', 'relevant', 'reliable', 'relieve', 'religion', 'remain', 'remark', 'remedy', 
         'remember', 'remembrance', 'remind', 
         'remission', 'remove', 'removal', 'render', 'renew', 'renewal', 'renounce', 'renunciation', 
         'repeatedly', 'repel', 'repentance', 'reply', 'repose', 'representation', 'reprimand', 
         'reproach', 'reprobate', 'reprove', 'require', 'requirement', 'resemblance', 'resemble', 'resent', 'resentfully', 
         'resentment', 'reside', 'resist', 'resistance', 'resolve', 'respect', 'responsibility', 'responsible', 
         'restore', 'restrain', 'resultant', 'resume', 'resurrection', 'resuscitate', 'retire', 
         'reveal', 'revel', 'revelation', 'revenge', 'revere', 'reverence', 'reverent', 'reverse', 
         'revive', 'reward', 'rhythm', 'rich', 'richly', 'right', 'rightly', 'ripe', 'ripen', 'rise', 'river', 'road', 
         'roam', 'robe', 'rock', 'role', 'roof', 'room', 'rose', 'rough', 'rouse', 'royalty', 'ruin', 
         'rule', 'run', 'runaway', 'rush', 'rust', 
         'Sabbaoth', 'Sabbath', 'sad', 'sadden', 'safe', 'sage', 'sail', 'saint', 'sake', 
         'salt', 'salvation', 'salve', 'salvific', 'Samuel', 'sanctification', 'sanctify', 'sapphire', 
         'satiety', 'satisfy', 'Saul', 'savage', 'savagery', 'save', 'savior', 'savor', 'say', 'scandalize', 'scapular', 
         'scatter', 'science', 'scream', 'scripture', 'scrutinize', 'search', 'season', 'seat', 
         'second', 'secondarily', 'secondary', 'secret', 'secretly', 'secular', 'secure', 'see', 
         'seek', 'seem', 'seer', 'seize', 'self', 'self-control', 'self-existent', 
         'self-love', 'sell', 'send', 'sensation', 'sensible', 'sensitive', 'sensitivity', 
         'sensor', 'sensory', 'sentence', 'separable', 'separate', 'separately', 
         'separation', 'sequence', 'Serapion', 'serenely', 'serpent', 'servant', 'serve', 'service', 
         'servitude', 'set', 'settle', 'seven', 'seventh', 'severe', 'sexual', 'shade', 'shaft', 'shake', 
         'shame', 'shameful', 'shamefully', 'shamelessly', 'sharer', 
         'sharp', 'sharply', 'sheep', 'shelter', 'sheepskin', 'sheer', 'shepherd', 'shield', 'shine', 
         'shock', 'shoe', 'shoot', 'shore', 'short', 'shoulder', 'shout', 'show', 'showbread', 'sick', 'side', 
         'sieze', 'sift', 'sight', 'sign', 'significance', 'signify', 'silent', 'silver', 
         'similar', 'similarity', 'similarly', 'simple', 'simplicity', 'simply', 'simultaneously', 
         'since', 'sing', 'single', 'sinner', 'Sion', 'sir', 'Sisara', 'sister', 'sit', 'situation', 'six', 'sixth', 
         'sixty', 'size', 'sky', 'slander', 'slanderer', 'slave', 'slay', 'sleepy', 'slip', 'slow', 'small', 
         'smell', 'smoke', 'snake', 'snake-fighter', 'snare', 'snatch', 'sociable', 'society', 'soft', 'soften', 
         'sojourn', 'sole', 'solely', 'solitary', 'solitude', 'Solomon', 'someone', 'somewhere', 
         'son', 'song', 'soon', 'soothe', 'sorrow', 'sorrowful', 'sorry', 'sort', 'soul', 'soundly', 
         'source', 'sow', 'sower', 'spare', 'sparingly', 'speak', 'specially', 'speech', 'spend', 
         'spherical', 'spirit', 'spiritual', 'spiritually', 'spite', 'spiteful', 'spleen', 
         'splendid', 'spread', 'sprout', 'square', 'stabilize', 'stable', 'staff', 'stage', 'stain', 'stamp', 'stanch', 'stand', 
         'star', 'state', 'statement', 'statue', 'stay', 'steadfast', 'steadfastly', 'steady', 'steal', 'steer', 'stench', 
         'sterile', 'steward', 'still', 'stir', 'stomach', 'stone', 'stoop', 'stop', 'store', 'storm', 'story', 
         'straight', 'strange', 'stranger', 'straw', 'strength', 'strengthen', 'stretch', 'strife', 'strike', 'strip', 
         'strive', 'stroke', 'strong', 'structure', 'stumble', 'stun', 'subdue', 'subjacent', 
         'subjection', 'submit', 'submission', 'submissive', 'subsequent', 'subsist', 'subsistent', 
         'substance', 'substantial', 'substantially', 'subtle', 'successfully', 'succinum', 
         'suceptible', 'sudden', 'suddenly', 'suffer', 'suffice', 'sufficient', 'suffocate', 'suggest', 'suit', 
         'suitable', 'summarize', 'summer', 'summit', 'summon', 'sun', 'sunlight', 'sunnoia', 'superior', 
         'supernatural', 'supplicate', 'supplication', 'support', 'suppose', 'supreme', 'surface', 
         'surpass', 'surprise', 'surrender', 'surround', 'survive', 'susceptible', 'sweat', 'sweet', 'swine', 
         'sword', 'symbol', 'symbolic', 'symbolically', 'symphony', 'symptom', 'Syriac', 
         'Tabennesiote', 'tabernacle', 'table', 'tablet', 'tackle', 'take', 'talent', 'talk', 'task',  
         'tasty', 'teach', 'teacher', 'tearfully', 'tell', 'temper', 'temperament', 
         'temperance', 'temperate', 'temple', 'temporal', 'temporary', 'tempt', 'temptation', 'ten', 
         'tent', 'Teqoa', 'term', 'terminology', 'terrible', 'terribly', 'terrify', 'terror', 'testify', 'tetrad', 
         'text', 'thankful', 'theme', 'Theodore', 'theologian', 'theologike', 'theology', 
         'thereby', 'therefore', 'thicken', 'thief', 'thigh', 'thing', 'think', 'third', 'thirst', 'thirty',  
         'thoughtful', 'thousand', 'threat', 'threaten', 'three', 'threshhold', 'throat', 'throughout', 'throw', 
         'thumikon', 'tie', 'till', 'today', 'together', 'toil', 'token', 'tolerate', 'tomb', 
         'tomorrow', 'tone', 'tongue', 'tool', 'torment', 'torturer', 'toss', 'total', 'totality', 'toward', 
         'tower', 'town', 'trace', 'track', 'tradition', 'train', 'traitor', 'trample', 'tranquil', 'tranquility', 
         'transform', 'transformation', 'transgress', 'transition', 'trap', 'travel', 'treasure', 'treasurer', 
         'treat', 'treatise', 'treatment', 'trick', 'tree', 'tremble', 'triad', 'triangular', 'tribunal', 
         'Trinity', 'triumph', 'true', 'truly', 'trumpet', 'trust', 'truth', 'truthful', 
         'try', 'turban', 'turmoil', 'turn', 'twenty', 'twenty-eight', 'twenty-five', 'twenty-four', 
         'twice', 'two', 'twofold', 
         'ultimate', 'ultimately', 'unable', 'unavailability', 'unaware', 'unbegotten', 
         'unbreakable', 'unclean', 'uncontrollable', 'understand', 'undertake', 'ungodly', 
         'ungrateful', 'unhealthy', 'uniform', 'union', 'unique', 'unit', 'unite', 'unity', 'universally', 
         'universe', 'unjust', 'unjustly', 'unknown', 'unlawful', 'unlike', 'unmerciful', 
         'unpleasant', 'unreal', 'unseen', 'unshakable', 'unspeakable', 'untimely', 
         'untrue', 'untruly', 'unwaveringly', 'upper', 'upright', 'uproot', 'upset', 'urge', 
         'urgently', 'useful', 'usual', 'usually', 'utter', 'utterly', 
         'vague', 'vain', 'vainglory', 'vainly', 'valiantly', 'vanish', 'vanity', 'variable', 
         'variation', 'variety', 'vary', 'vein', 'vengeance', 'vengeful', 'venture', 'verse', 'version', 'vessel', 
         'vice', 'victim', 'view', 'vigil', 'vigilance', 'vigor', 'vigorously', 'village', 'violently', 'viper', 
         'virgin', 'virtue', 'visible', 'vision', 'visit', 'vivify', 'voluntarily', 'voluntary', 
         'vow', 'vulnerable', 'vulture', 
         'wage', 'wait', 'wake', 'walk', 'wall', 'wander', 'wanderer', 'want', 'wanton', 'war', 'warm', 'warmth', 'watch', 'watchful', 'watchman', 
         'water', 'wave', 'wax', 'way', 'weak', 'weaken', 'wealth', 'wealthy', 'weapon', 'wear', 'weary', 'week', 'weep', 
         'weigh', 'weight', 'welcome', 'weld', 'well-said', 'west', 'whatever', 'wheat', 'wheel', 'whenever', 
         'whereby', 'wherefore', 'wherein', 'whether', 'whetstone', 'whichever', 'whither', 
         'whoever', 'whole', 'wholly', 'widen', 'widow', 'width', 'wife', 'wild', 'willing', 
         'willingly', 'win', 'wind', 'window', 'wine', 'wine-jar', 'wing', 'wink', 'winnower', 'wipe', 
         'wisdom', 'wise', 'wish', 'withdraw', 'withdrawal', 'withdrawn', 'within', 'without', 'witness', 
         'wolf', 'woman', 'womb', 'won', 'wood', 'wooden', 'word', 'Word-God', 'worker', 
         'world', 'worldly', 'worm', 'worry', 'worse', 'worship', 'worst', 'worth', 'worthy', 
         'wound', 'wrap', 'wreak', 'wrest', 'wrestle', 'wrestler', 'wretch', 'write', 'writer', 
         'wrongdoer', 
         'year', 'yearn', 'yesterday', 'yet', 'yield', 'yoke', 'young', 'youth', 
         'zeal', 'zealously', 'zenith', 'Zion'
         "/>

   <xsl:variable name="lemmas.eng" as="map(*)">
      <xsl:map>
         <xsl:for-each select="$eng.words.standard">
            <xsl:map-entry key=".">{.}</xsl:map-entry>
         </xsl:for-each>
         <xsl:map-entry key="'accompanies'">accompany</xsl:map-entry>
         <xsl:map-entry key="'accompanied'">accompany</xsl:map-entry>
         <xsl:map-entry key="'achieving'">achieve</xsl:map-entry>
         <xsl:map-entry key="'acquiring'">acquire</xsl:map-entry>
         
         <xsl:map-entry key="'account'">account (n.)</xsl:map-entry>
         <xsl:map-entry key="'accounted'">account (v.)</xsl:map-entry>
         <xsl:map-entry key="'accounting'">account (v.)</xsl:map-entry>
         <xsl:map-entry key="'act'">
            <matches pattern="(in|the) act">act (n.)</matches>
            <otherwise>act (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'acts'">
            <matches pattern="(through) acts">act (n.)</matches>
            <otherwise>act (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'acted'">act (v.)</xsl:map-entry>
         <xsl:map-entry key="'activities'">activity</xsl:map-entry>
         <xsl:map-entry key="'Acts'">
            <matches pattern="Acts \d"/>
            <matches pattern="Acts of the|through acts">act (n.)</matches>
            <otherwise>act (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'advance'">
            <matches pattern="in advance">advance (n.)</matches>
            <otherwise>advance (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'adversaries'">adversary</xsl:map-entry>
         <xsl:map-entry key="'amazing'">amaze</xsl:map-entry>
         <xsl:map-entry key="'announcing'">announce</xsl:map-entry>
         <xsl:map-entry key="'answer'">
            <matches pattern="an answer">answer (n.)</matches>
            <otherwise>answer (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'anxieties'">anxiety</xsl:map-entry>
         <xsl:map-entry key="'applied'">apply</xsl:map-entry>
         <xsl:map-entry key="'applies'">apply</xsl:map-entry>
         <xsl:map-entry key="'approach'">
            <matches pattern="(an|first \[) approach">approach (n.)</matches>
            <otherwise>approach (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'arising'">arise</xsl:map-entry>
         <xsl:map-entry key="'arm'">arm (v.)</xsl:map-entry>
         <xsl:map-entry key="'arms'">arm (n.)</xsl:map-entry>
         <xsl:map-entry key="'asctical'">ascetical</xsl:map-entry>
         <xsl:map-entry key="'ate'">eat</xsl:map-entry>
         <xsl:map-entry key="'attack'">
            <matches pattern="(the|preliminary) attack">attack (n.)</matches>
            <otherwise>attack (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'attempt'">
            <matches pattern="(the|your|second) attempt">attempt (n.)</matches>
            <otherwise>attempt (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Baalim'">Balaam</xsl:map-entry>
         <xsl:map-entry key="'baptizing'">baptize</xsl:map-entry>
         <xsl:map-entry key="'began'">begin</xsl:map-entry>
         <xsl:map-entry key="'begat'">beget</xsl:map-entry>
         <xsl:map-entry key="'begot'">beget</xsl:map-entry>
         <xsl:map-entry key="'begotten'">
            <matches pattern="-begotten|begotten is one|“begotten”">begotten</matches>
            <otherwise>beget</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'begun'">begin</xsl:map-entry>
         <xsl:map-entry key="'beheld'">behold</xsl:map-entry>
         <xsl:map-entry key="'Being'"/>
         <xsl:map-entry key="'being'">
            <matches pattern="(brings?|comes?|non-being) into being">being</matches>
            <matches pattern="(living|His\]?|the|immaterial|human) being">being</matches>
            <matches pattern="imprints its being">being</matches>
            <matches pattern="(incorporeal|created) \[being">being</matches>
            <otherwise/>
         </xsl:map-entry>
         <xsl:map-entry key="'beings'">being</xsl:map-entry>
         <xsl:map-entry key="'benefit'">
            <matches pattern="to benefit">benefit (v.)</matches>
            <otherwise>benefit (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'bidding'">bid</xsl:map-entry>
         <xsl:map-entry key="'bitten'">bite</xsl:map-entry>
         <xsl:map-entry key="'blaspheming'">blaspheme</xsl:map-entry>
         <xsl:map-entry key="'blind'">
            <matches pattern="born blind">blind (adj.)</matches>
            <otherwise>blind (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'blow'">
            <matches pattern="through blow">blow (n.)</matches>
            <otherwise>blow (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'bodies'">body</xsl:map-entry>
         <xsl:map-entry key="'bore'">bear</xsl:map-entry>
         <xsl:map-entry key="'born'">
            <matches pattern="first\s*-born">firstborn</matches>
            <matches pattern="born blind">born (adj.)</matches>
            <otherwise>bear</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'bound'">
            <matches pattern="go bounding">bound (v.)</matches>
            <matches pattern="taken bound|bound to earth">bound (adj.)</matches>
            <matches pattern="(are|he) bound">bind</matches>
            <otherwise>bind</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'boundaries'">boundary</xsl:map-entry>
         <xsl:map-entry key="'brethren'">brother</xsl:map-entry>
         <xsl:map-entry key="'brought'">bring</xsl:map-entry>
         <xsl:map-entry key="'built'">build</xsl:map-entry>
         <xsl:map-entry key="'buried'">bury</xsl:map-entry>
         <xsl:map-entry key="'burn'">burn</xsl:map-entry>
         <xsl:map-entry key="'burning'">
            <matches pattern="(of|was|bush) burning">burn</matches>
            <otherwise>burning</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'care'">care (n.)</xsl:map-entry>
         <xsl:map-entry key="'cares'">
            <matches pattern="constant cares">care (n.)</matches>
            <otherwise>care (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'cave'">cave (v.)</xsl:map-entry>
         <xsl:map-entry key="'caves'">cave (n.)</xsl:map-entry>
         <xsl:map-entry key="'centuries'">century</xsl:map-entry>
         <xsl:map-entry key="'carried'">carry</xsl:map-entry>
         <xsl:map-entry key="'carries'">carry</xsl:map-entry>
         <xsl:map-entry key="'caught'">catch</xsl:map-entry>
         <xsl:map-entry key="'causing'">cause</xsl:map-entry>
         <xsl:map-entry key="'change'">
            <matches pattern="will change">change (v.)</matches>
            <otherwise>change (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'changed'">change (v.)</xsl:map-entry>
         <xsl:map-entry key="'changes'">
            <matches pattern="(the|of) changes">change (n.)</matches>
            <otherwise>change (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'changing'">change (v.)</xsl:map-entry>
         <xsl:map-entry key="'charge'">charge (n.)</xsl:map-entry>
         <xsl:map-entry key="'charged'">charge (v.)</xsl:map-entry>
         <xsl:map-entry key="'charges'">charge (v.)</xsl:map-entry>
         <xsl:map-entry key="'chasing'">chase</xsl:map-entry>
         <xsl:map-entry key="'cherubim'">cherub</xsl:map-entry>
         <xsl:map-entry key="'children'">child</xsl:map-entry>
         <xsl:map-entry key="'chose'">choose</xsl:map-entry>
         <xsl:map-entry key="'chosen'">
            <matches pattern="be chosen">choose</matches>
            <otherwise>chosen</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'CHRIST'">Christ</xsl:map-entry>
         <xsl:map-entry key="'Christs'">Christ</xsl:map-entry>
         <xsl:map-entry key="'circling'">circle</xsl:map-entry>
         <xsl:map-entry key="'cities'">city</xsl:map-entry>
         <xsl:map-entry key="'clear'">
            <matches pattern="virtues clear">clear (v.)</matches>
            <otherwise>clear (adj.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'cleared'">clear (v.)</xsl:map-entry>
         <xsl:map-entry key="'close'">
            <matches pattern="close to elements">close (adj.)</matches>
            <otherwise>close (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'closer'">close (adj.)</xsl:map-entry>
         <xsl:map-entry key="'clothes'">clothes</xsl:map-entry>
         <xsl:map-entry key="'clothing'">clothe</xsl:map-entry>
         <xsl:map-entry key="'co-essential'">coessential</xsl:map-entry>
         <xsl:map-entry key="'co-heir'">coheir</xsl:map-entry>
         <xsl:map-entry key="'co-inheritor'">coinheritor</xsl:map-entry>
         <xsl:map-entry key="'colour'">color</xsl:map-entry>
         <xsl:map-entry key="'colours'">colors</xsl:map-entry>
         <xsl:map-entry key="'committed'">commit</xsl:map-entry>
         <xsl:map-entry key="'committing'">commit</xsl:map-entry>
         <xsl:map-entry key="'communities'">community</xsl:map-entry>
         <xsl:map-entry key="'compelled'">compel</xsl:map-entry>
         <xsl:map-entry key="'completing'">complete</xsl:map-entry>
         <xsl:map-entry key="'concern'">
            <matches pattern="sensible concern">concern (n.)</matches>
            <otherwise>concern (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'concerns'">concern (v.)</xsl:map-entry>
         <xsl:map-entry key="'conduct'">
            <matches pattern="(pure|of) conduct">conduct (n.)</matches>
            <otherwise>conduct (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'conferring'">confer</xsl:map-entry>
         <xsl:map-entry key="'con-substantial'">consubstantial</xsl:map-entry>
         <xsl:map-entry key="'contemplating'">contemplate</xsl:map-entry>
         <xsl:map-entry key="'contraries'">contrary</xsl:map-entry>
         <xsl:map-entry key="'corporal'">corporeal</xsl:map-entry>
         <xsl:map-entry key="'cover'">
            <matches pattern="a cover">cover (n.)</matches>
            <otherwise>cover (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'creating'">create</xsl:map-entry>
         <xsl:map-entry key="'cries'">cry (n.)</xsl:map-entry>
         <xsl:map-entry key="'cross'">
            <matches pattern="(to|cannot) cross">cross (v.)</matches>
            <otherwise>cross (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'crossed'">cross (v.)</xsl:map-entry>
         <xsl:map-entry key="'crucified'">crucify</xsl:map-entry>
         <xsl:map-entry key="'cry'">cry (v.)</xsl:map-entry>
         <xsl:map-entry key="'cutting'">cut</xsl:map-entry>
         <xsl:map-entry key="'Cæsareans'">Caesarean</xsl:map-entry>
         <xsl:map-entry key="'deal'">deal (n.)</xsl:map-entry>
         <xsl:map-entry key="'dealing'">deal (v.)</xsl:map-entry>
         <xsl:map-entry key="'decorating'">decorate</xsl:map-entry>
         <xsl:map-entry key="'defeat'">
            <matches pattern="to defeat">defeat (v.)</matches>
            <otherwise>defeat (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'defeated'">defeat (v.)</xsl:map-entry>
         <xsl:map-entry key="'defence'">defense</xsl:map-entry>
         <xsl:map-entry key="'defendent'">defendant</xsl:map-entry>
         <xsl:map-entry key="'defiling'">defile</xsl:map-entry>
         <xsl:map-entry key="'dæmon'">demon</xsl:map-entry>
         <xsl:map-entry key="'dæmons'">demon</xsl:map-entry>
         <xsl:map-entry key="'denies'">deny</xsl:map-entry>
         <xsl:map-entry key="'desert'">
            <matches pattern="not desert">desert (v.)</matches>
            <otherwise>desert (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'deserving'">deserve</xsl:map-entry>
         <xsl:map-entry key="'desire'">
            <matches pattern="(makes him|make us|you) desire">desire (v.)</matches>
            <otherwise>desire (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'desires'">
            <matches pattern="(soul|who|never) desires">desire (v.)</matches>
            <matches pattern="desires virtue">desire (v.)</matches>
            <otherwise>desire (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'desired'">desire (v.)</xsl:map-entry>
         <xsl:map-entry key="'desiring'">desire (v.)</xsl:map-entry>
         <xsl:map-entry key="'difficulties'">difficulty</xsl:map-entry>
         <xsl:map-entry key="'discuss'">
            <matches pattern="discuss\[ion">discussion</matches>
            <otherwise>discuss</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'dispersing'">disperse</xsl:map-entry>
         <xsl:map-entry key="'display'">
            <matches pattern="the display">display (n.)</matches>
            <otherwise>display (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'disposing'">dispose</xsl:map-entry>
         <xsl:map-entry key="'dissipating'">dissipate</xsl:map-entry>
         <xsl:map-entry key="'distance'">
            <matches pattern="their distance">distance (n.)</matches>
            <otherwise>distance (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'distancing'">distance (v.)</xsl:map-entry>
         <xsl:map-entry key="'distress'">distress (n.)</xsl:map-entry>
         <xsl:map-entry key="'distressed'">distress (v.)</xsl:map-entry>
         <xsl:map-entry key="'distressing'">distress (v.)</xsl:map-entry>
         <xsl:map-entry key="'dividing'">divide</xsl:map-entry>
         <xsl:map-entry key="'dragging'">drag</xsl:map-entry>
         <xsl:map-entry key="'drank'">drink</xsl:map-entry>
         <xsl:map-entry key="'drawn'">draw</xsl:map-entry>
         <xsl:map-entry key="'drew'">draw</xsl:map-entry>
         <xsl:map-entry key="'driven'">drive</xsl:map-entry>
         <xsl:map-entry key="'drove'">drive</xsl:map-entry>
         <xsl:map-entry key="'dwelling'">
            <matches pattern="mischief dwelling">dwell</matches>
            <otherwise>dwelling</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'dwellings'">dwelling</xsl:map-entry>
         <xsl:map-entry key="'dwelt'">dwell</xsl:map-entry>
         <xsl:map-entry key="'earlier'">early</xsl:map-entry>
         <xsl:map-entry key="'easier'">easy</xsl:map-entry>
         <xsl:map-entry key="'effect'">effect (n.)</xsl:map-entry>
         <xsl:map-entry key="'effected'">effect (v.)</xsl:map-entry>
         <xsl:map-entry key="'effects'">
            <matches pattern="Justice effects">effect (v.)</matches>
            <otherwise>effect (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Egyptians'">Egyptian</xsl:map-entry>
         <xsl:map-entry key="'elucidating'">elucidate</xsl:map-entry>
         <xsl:map-entry key="'embodied'">embody</xsl:map-entry>
         <xsl:map-entry key="'embracing'">embrace</xsl:map-entry>
         <xsl:map-entry key="'enabling'">enable</xsl:map-entry>
         <xsl:map-entry key="'encircling'">encircle</xsl:map-entry>
         <xsl:map-entry key="'encouraging'">encourage</xsl:map-entry>
         <xsl:map-entry key="'end'">
            <matches pattern="will end">end (v.)</matches>
            <otherwise>end (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'enemies'">enemy</xsl:map-entry>
         <xsl:map-entry key="'enquire'">inquire</xsl:map-entry>
         <xsl:map-entry key="'enquiring'">inquire</xsl:map-entry>
         <xsl:map-entry key="'enquiry'">inquiry</xsl:map-entry>
         <xsl:map-entry key="'épithumia'">epithumia</xsl:map-entry>
         <xsl:map-entry key="'epithumiais'">epithumia</xsl:map-entry>
         <xsl:map-entry key="'exercise'">
            <matches pattern="diligent exercise">exercise (n.)</matches>
            <otherwise>exercise (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'exercising'">exercise (v.)</xsl:map-entry>
         <xsl:map-entry key="'expelled'">expel</xsl:map-entry>
         <xsl:map-entry key="'experience'">
            <matches pattern="(the|by) experience|experience is">experience (n.)</matches>
            <otherwise>experience (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'face'">face (n.)</xsl:map-entry>
         <xsl:map-entry key="'faced'">face (v.)</xsl:map-entry>
         <xsl:map-entry key="'facing'">face (v.)</xsl:map-entry>
         <xsl:map-entry key="'faculties'">faculty</xsl:map-entry>
         <xsl:map-entry key="'fall'">
            <matches pattern="worst fall">fall (n.)</matches>
            <otherwise>fall (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'falls'">
            <matches pattern="the falls">fall (n.)</matches>
            <otherwise>fall (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'fallen'">
            <matches pattern="fallen-away">fallen</matches>
            <matches pattern="the fallen">fallen</matches>
            <matches pattern="fallen passions">fallen</matches>
            <otherwise>fall (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'fantasies'">fantasy</xsl:map-entry>
         <xsl:map-entry key="'favour'">favor</xsl:map-entry>
         <xsl:map-entry key="'fear'">
            <matches pattern="(the|this|susceptible to|for|in) fear">fear (n.)</matches>
            <matches pattern="[Ff]ear (is|of)">fear (n.)</matches>
            <otherwise>fear (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'feast'">feast (v.)</xsl:map-entry>
         <xsl:map-entry key="'feasts'">feast (n.)</xsl:map-entry>
         <xsl:map-entry key="'fed'">feed</xsl:map-entry>
         <xsl:map-entry key="'feeling'">
            <matches pattern="feeling part">feeling</matches>
            <otherwise>feel</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'feet'">foot</xsl:map-entry>
         <xsl:map-entry key="'fell'">fall (v.)</xsl:map-entry>
         <xsl:map-entry key="'felt'">feel</xsl:map-entry>
         <xsl:map-entry key="'fight'">
            <matches pattern="the fight">fight (n.)</matches>
            <otherwise>fight (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'flavour'">flavor</xsl:map-entry>
         <xsl:map-entry key="'flavours'">flavor</xsl:map-entry>
         <xsl:map-entry key="'first-born'">firstborn</xsl:map-entry>
         <xsl:map-entry key="'fled'">flee</xsl:map-entry>
         <xsl:map-entry key="'flies'">fly (n.)</xsl:map-entry>
         <xsl:map-entry key="'fleeter'">fleet</xsl:map-entry>
         <xsl:map-entry key="'fly'">fly (v.)</xsl:map-entry>
         <xsl:map-entry key="'force'">
            <matches pattern="(the|their) force">force (n.)</matches>
            <otherwise>force (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'forces'">
            <matches pattern="(the|natural) forces">force (n.)</matches>
            <otherwise>force (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'forcing'">force (v.)</xsl:map-entry>
         <xsl:map-entry key="'forgetting'">forget</xsl:map-entry>
         <xsl:map-entry key="'forgotten'">forget</xsl:map-entry>
         <xsl:map-entry key="'form'">
            <matches pattern="form in your mind">form (v.)</matches>
            <matches pattern="(not|thought|that\]) form">form (v.)</matches>
            <otherwise>form (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'formed'">form (v.)</xsl:map-entry>
         <xsl:map-entry key="'forming'">form (v.)</xsl:map-entry>
         <xsl:map-entry key="'forms'">form (n.)</xsl:map-entry>
         <xsl:map-entry key="'forsaken'">forsake</xsl:map-entry>
         <xsl:map-entry key="'forwards'">forward</xsl:map-entry>
         <xsl:map-entry key="'found'">
            <matches pattern="found varied worlds">found</matches>
            <otherwise>find</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'founded'">found</xsl:map-entry>
         <xsl:map-entry key="'Frank'">
            <matches pattern="Mel\. Frank"/>
            <otherwise>frank</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'ful'">
            <matches pattern="ful\[ly\]">fully</matches>
            <otherwise/>
         </xsl:map-entry>
         <xsl:map-entry key="'fulfil'">fulfill</xsl:map-entry>
         <xsl:map-entry key="'genitor'">
            <matches pattern="pro\]genitor"/>
            <otherwise>genitor</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'gave'">give</xsl:map-entry>
         <xsl:map-entry key="'gazing'">gaze</xsl:map-entry>
         <xsl:map-entry key="'given'">give</xsl:map-entry>
         <xsl:map-entry key="'giving'">give</xsl:map-entry>
         <xsl:map-entry key="'glimpsing'">glimpse</xsl:map-entry>
         <xsl:map-entry key="'glorified'">glorify</xsl:map-entry>
         <xsl:map-entry key="'gnostikoi'">gnostikos</xsl:map-entry>
         <xsl:map-entry key="'gnowledge'">knowledge</xsl:map-entry>
         <xsl:map-entry key="'Greeks'">Greek</xsl:map-entry>
         <xsl:map-entry key="'grew'">grow</xsl:map-entry>
         <xsl:map-entry key="'groans'">groan</xsl:map-entry>
         <xsl:map-entry key="'groaning'">groaning</xsl:map-entry>
         <xsl:map-entry key="'grown'">grow</xsl:map-entry>
         <xsl:map-entry key="'habit'">
            <matches pattern="habit\[ual">habitual</matches>
            <otherwise>habit</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'hand'">hand (n.)</xsl:map-entry>
         <xsl:map-entry key="'hands'">
            <matches pattern="hands over">hand (v.)</matches>
            <otherwise>hand (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'heard'">hear</xsl:map-entry>
         <xsl:map-entry key="'heavier'">heavy</xsl:map-entry>
         <xsl:map-entry key="'Hebrews'">Hebrew</xsl:map-entry>
         <xsl:map-entry key="'held'">hold</xsl:map-entry>
         <xsl:map-entry key="'help'">
            <matches pattern="(this|’s|for) help">help (n.)</matches>
            <otherwise>help (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'hidden'">
            <matches pattern="(is|are|was) hidden">hide</matches>
            <matches pattern="hidden in">hide</matches>
            <otherwise>hidden</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'ual'">
            <matches pattern="habit\[ual"/>
            <otherwise>ual</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'honour'">honor</xsl:map-entry>
         <xsl:map-entry key="'honours'">honor</xsl:map-entry>
         <xsl:map-entry key="'ignoring'">ignore</xsl:map-entry>
         <xsl:map-entry key="'illuminating'">illuminate</xsl:map-entry>
         <xsl:map-entry key="'imaginings'">imagining</xsl:map-entry>
         <xsl:map-entry key="'impassable'">impassible</xsl:map-entry>
         <xsl:map-entry key="'imprint'">
            <matches pattern="(the|from) imprint">imprint (n.)</matches>
            <otherwise>imprint (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'imprints'">
            <matches pattern="([Tt]he) imprint">imprint (n.)</matches>
            <otherwise>imprint (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'incabable'">incapable</xsl:map-entry>
         <xsl:map-entry key="'increase'">
            <matches pattern="(receives|of|an|the|in) increase">increase (n.)</matches>
            <otherwise>increase (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'increases'">
            <matches pattern="(receives|of|an|the|in) increase">increase (n.)</matches>
            <otherwise>increase (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'increasing'">increase (v.)</xsl:map-entry>
         <xsl:map-entry key="'indicating'">indicate</xsl:map-entry>
         <xsl:map-entry key="'indwelling'">indwell</xsl:map-entry>
         <xsl:map-entry key="'in-dwelling'">indwelling</xsl:map-entry>
         <xsl:map-entry key="'infirmities'">infirmity</xsl:map-entry>
         <xsl:map-entry key="'injuries'">injury</xsl:map-entry>
         <xsl:map-entry key="'intelligilble'">intelligible</xsl:map-entry>
         <xsl:map-entry key="'interfering'">interfere</xsl:map-entry>
         <xsl:map-entry key="'intermediaries'">intermediary</xsl:map-entry>
         <xsl:map-entry key="'œconomy'">economy</xsl:map-entry>
         <xsl:map-entry key="'ions'">
            <matches pattern="\]ions"/>
            <matches pattern="\[ions\]"/>
            <otherwise>ions</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Israelites'">Israelite</xsl:map-entry>
         <xsl:map-entry key="'Jesus'">Jesus</xsl:map-entry>
         <xsl:map-entry key="'Jonas'">Jonah</xsl:map-entry>
         <xsl:map-entry key="'Juda'">Judah</xsl:map-entry>
         <xsl:map-entry key="'judgement'">judgment</xsl:map-entry>
         <xsl:map-entry key="'judgements'">judgment</xsl:map-entry>
         <xsl:map-entry key="'juster'">just</xsl:map-entry>
         <xsl:map-entry key="'kept'">keep</xsl:map-entry>
         <xsl:map-entry key="'knew'">know</xsl:map-entry>
         <xsl:map-entry key="'known'">know</xsl:map-entry>
         <xsl:map-entry key="'labor'">
            <matches pattern="watchman labor">labor (v.)</matches>
            <otherwise>labor (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'laboring'">labor (v.)</xsl:map-entry>
         <xsl:map-entry key="'labour'">labor (n.)</xsl:map-entry>
         <xsl:map-entry key="'labours'">labor (n.)</xsl:map-entry>
         <xsl:map-entry key="'last'">
            <matches pattern="does not last">last (v.)</matches>
            <otherwise>last (adj.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'lasting'">last (v.)</xsl:map-entry>
         <xsl:map-entry key="'lead'">
            <matches pattern="(the) lead">lead (n.)</matches>
            <otherwise>lead (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'least'">less</xsl:map-entry>
         <xsl:map-entry key="'led'">lead (v.)</xsl:map-entry>
         <xsl:map-entry key="'left'">
            <matches pattern="left eye">left</matches>
            <matches pattern="the left">left</matches>
            <otherwise>leave</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Let'">
            <matches pattern="Let to Mel\."/>
            <otherwise>let</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Letter'">
            <matches pattern="Letter \d+"/>
            <otherwise>letter</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'level'">
            <matches pattern="the level">level (n.)</matches>
            <otherwise>level (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'levelled'">level (v.)</xsl:map-entry>
         <xsl:map-entry key="'levelling'">level (v.)</xsl:map-entry>
         <xsl:map-entry key="'lighter'">light (adj.)</xsl:map-entry>
         <xsl:map-entry key="'light'">
            <matches pattern="makes light">light (adj.)</matches>
            <otherwise>light (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'lights'">
            <matches pattern="he (himself )?lights">light (v.)</matches>
            <otherwise>light (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'like'">like (prep.)</xsl:map-entry>
         <xsl:map-entry key="'likes'">like (v.)</xsl:map-entry>
         <xsl:map-entry key="'limit'">
            <matches pattern="who limit">limit (v.)</matches>
            <otherwise>limit (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'lit'">
            <!-- "literally" -->
            <matches pattern="\[lit(\.| |:)"/>
            <otherwise>light (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'lives'">
            <matches pattern="(second|whose|three|the|pure) lives">life</matches>
            <otherwise>live</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'living'">
            <matches pattern="living in">live</matches>
            <matches pattern="is living">live</matches>
            <otherwise>living</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'loaves'">loaf</xsl:map-entry>
         <xsl:map-entry key="'logikoi'">logikos</xsl:map-entry>
         <xsl:map-entry key="'logismoi'">logismos</xsl:map-entry>
         <xsl:map-entry key="'logoi'">logos</xsl:map-entry>
         <xsl:map-entry key="'longer'">long</xsl:map-entry>
         <xsl:map-entry key="'love'">
            <matches pattern="To love all">love (v.)</matches>
            <matches pattern="(cannot|will|not|you) love">love (v.)</matches>
            <matches pattern="Love (the Lord|your sisters)">love (v.)</matches>
            <otherwise>love (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'loving'">love (v.)</xsl:map-entry>
         <xsl:map-entry key="'loves'">love (v.)</xsl:map-entry>
         <xsl:map-entry key="'lowered'">lower</xsl:map-entry>
         <xsl:map-entry key="'lying'">lie</xsl:map-entry>
         <xsl:map-entry key="'Macarios'">Macarius</xsl:map-entry>
         <xsl:map-entry key="'Macarius'">Macarius</xsl:map-entry>
         <xsl:map-entry key="'made'">make</xsl:map-entry>
         <xsl:map-entry key="'Maxims'">
            <matches pattern="Maxims \d"/>
            <otherwise>maxims</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'mean'">
            <matches pattern="mean time">meantime</matches>
            <otherwise>mean (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'meaning'">
            <matches pattern="not meaning">mean (v.)</matches>
            <matches pattern="meaning by">mean (v.)</matches>
            <otherwise>meaning</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'means'">
            <matches pattern="mortal. \[means">mean (v.)</matches>
            <matches pattern="means the same">mean (v.)</matches>
            <matches pattern="this word means">mean (v.)</matches>
            <otherwise>mean (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'meant'">mean (v.)</xsl:map-entry>
         <xsl:map-entry key="'measure'">
            <matches pattern="do not measure">measure (v.)</matches>
            <otherwise>measure (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'measured'">measure (v.)</xsl:map-entry>
         <xsl:map-entry key="'Mel'">
            <matches pattern="Mel\. Frank"/>
            <otherwise>mel</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Men'">man</xsl:map-entry>
         <xsl:map-entry key="'men'">man</xsl:map-entry>
         <xsl:map-entry key="'mention'">mention (n.)</xsl:map-entry>
         <xsl:map-entry key="'mentioned'">mention (v.)</xsl:map-entry>
         <xsl:map-entry key="'mentioning'">mention (v.)</xsl:map-entry>
         <xsl:map-entry key="'might'">
            <matches pattern="glory and might">might</matches>
            <matches pattern="all their might">might</matches>
            <otherwise/>
         </xsl:map-entry>
         <xsl:map-entry key="'minstrations'">ministration</xsl:map-entry>
         <xsl:map-entry key="'Mount'">mountain</xsl:map-entry>
         <xsl:map-entry key="'name'">name (n.)</xsl:map-entry>
         <xsl:map-entry key="'named'">name (v.)</xsl:map-entry>
         <xsl:map-entry key="'names'">
            <matches pattern="ly names">name (v.)</matches>
            <otherwise>name (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Nazarenes'">Nazarene</xsl:map-entry>
         <xsl:map-entry key="'need'">need (v.)</xsl:map-entry>
         <xsl:map-entry key="'needs'">
            <matches pattern="the needs">need (n.)</matches>
            <otherwise>need (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'news'">news</xsl:map-entry>
         <xsl:map-entry key="'nother'">
            <matches pattern=" a\]nother">another</matches>
            <otherwise>nother</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'no-one'">one</xsl:map-entry>
         <xsl:map-entry key="'noemata'">noema</xsl:map-entry>
         <xsl:map-entry key="'noes'">nous</xsl:map-entry>
         <xsl:map-entry key="'non-abandonment'">nonabandonment</xsl:map-entry>
         <xsl:map-entry key="'non-existence'">nonexistence</xsl:map-entry>
         <xsl:map-entry key="'non-existent'">nonexistent</xsl:map-entry>
         <xsl:map-entry key="'numerica'">numerical</xsl:map-entry>
         <xsl:map-entry key="'object'">
            <matches pattern="to object">object (v.)</matches>
            <otherwise>object (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'occupied'">occupy</xsl:map-entry>
         <xsl:map-entry key="'order'">order (n.)</xsl:map-entry>
         <xsl:map-entry key="'ordered'">order (v.)</xsl:map-entry>
         <xsl:map-entry key="'organa'">organon</xsl:map-entry>
         <xsl:map-entry key="'para'">
            <matches pattern="para physin"/>
            <otherwise>para</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'paid'">pay</xsl:map-entry>
         <xsl:map-entry key="'Pasch'">Pascha</xsl:map-entry>
         <xsl:map-entry key="'perfect'">perfect (adj.)</xsl:map-entry>
         <xsl:map-entry key="'perfected'">perfect (v.)</xsl:map-entry>
         <xsl:map-entry key="'perfecting'">perfect (v.)</xsl:map-entry>
         <xsl:map-entry key="'perfects'">perfect (v.)</xsl:map-entry>
         <xsl:map-entry key="'persecutest'">persecute</xsl:map-entry>
         <xsl:map-entry key="'phantasies'">fantasy</xsl:map-entry>
         <xsl:map-entry key="'phialên'">phiale</xsl:map-entry>
         <xsl:map-entry key="'philia'">philia</xsl:map-entry>
         <xsl:map-entry key="'Philistines'">Philistine</xsl:map-entry>
         <xsl:map-entry key="'physiké'">physike</xsl:map-entry>
         <xsl:map-entry key="'pity'">pity (n.)</xsl:map-entry>
         <xsl:map-entry key="'pities'">pity (v.)</xsl:map-entry>
         <xsl:map-entry key="'place'">
            <matches pattern="to place">place (v.)</matches>
            <otherwise>place (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'places'">
            <matches pattern="places within">place (v.)</matches>
            <otherwise>place (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'placed'">place (v.)</xsl:map-entry>
         <xsl:map-entry key="'placing'">place (v.)</xsl:map-entry>
         <xsl:map-entry key="'plan'">
            <matches pattern="divine plan">plan (n.)</matches>
            <otherwise>plan (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'posseses'">possess</xsl:map-entry>
         <xsl:map-entry key="'practise'">practice</xsl:map-entry>
         <xsl:map-entry key="'praktikē'">praktike</xsl:map-entry>
         <xsl:map-entry key="'praktiké'">praktike</xsl:map-entry>
         <xsl:map-entry key="'praktikoi'">praktikos</xsl:map-entry>
         <xsl:map-entry key="'preceed'">precede</xsl:map-entry>
         <xsl:map-entry key="'present'">
            <matches pattern="the present">present (n.)</matches>
            <matches pattern="are fully \[present">present (v.)</matches>
            <otherwise>present (adj.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'presented'">present (v.)</xsl:map-entry>
         <xsl:map-entry key="'presenting'">present (v.)</xsl:map-entry>
         <xsl:map-entry key="'presents'">present (v.)</xsl:map-entry>
         <xsl:map-entry key="'pro'">
            <matches pattern="pro\]genitor">progenitor</matches>
            <otherwise>pro</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'prob'">
            <matches pattern="\[prob\."/>
            <otherwise>prob</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'promise'">
            <matches pattern="[Tt]he promise">promise (n.)</matches>
            <otherwise>promise (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'promises'">
            <matches pattern="[Tt]he promises">promise (n.)</matches>
            <otherwise>promise (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'re-clothed'">reclothe</xsl:map-entry>
         <xsl:map-entry key="'reason'">reason (n.)</xsl:map-entry>
         <xsl:map-entry key="'reasons'">reason (n.)</xsl:map-entry>
         <xsl:map-entry key="'reasoned'">reason (v.)</xsl:map-entry>
         <xsl:map-entry key="'reasoning'">reason (v.)</xsl:map-entry>
         <xsl:map-entry key="'recognise'">recognize</xsl:map-entry>
         <xsl:map-entry key="'regard'">
            <matches pattern="(thus|not) regard">regard (v.)</matches>
            <matches pattern="regard them">regard (v.)</matches>
            <otherwise>regard (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'regards'">
            <matches pattern="(as|in) regards">regard (n.)</matches>
            <otherwise>regard (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'regarded'">regard (v.)</xsl:map-entry>
         <xsl:map-entry key="'Regarding'">regarding</xsl:map-entry>
         <xsl:map-entry key="'request'">request (n.)</xsl:map-entry>
         <xsl:map-entry key="'requested'">request (v.)</xsl:map-entry>
         <xsl:map-entry key="'requesting'">request (v.)</xsl:map-entry>
         <xsl:map-entry key="'rest'">
            <matches pattern="(the|spiritual) rest">rest (n.)</matches>
            <matches pattern="the first .rest">rest (n.)</matches>
            <otherwise>rest (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'return'">
            <matches pattern="(the|in) return">return (n.)</matches>
            <otherwise>return (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'result'">result (n.)</xsl:map-entry>
         <xsl:map-entry key="'resulted'">result (v.)</xsl:map-entry>
         <xsl:map-entry key="'resulting'">result (v.)</xsl:map-entry>
         <xsl:map-entry key="'round'">
            <matches pattern=" a round">around</matches>
            <otherwise>round</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sacrifice'">
            <matches pattern="spiritual sacrifice">sacrifice (n.)</matches>
            <otherwise>sacrifice (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sacrifices'">sacrifice (n.)</xsl:map-entry>
         <xsl:map-entry key="'said'">say</xsl:map-entry>
         <xsl:map-entry key="'sat'">sit</xsl:map-entry>
         <xsl:map-entry key="'saw'">see</xsl:map-entry>
         <xsl:map-entry key="'Saviour'">savior</xsl:map-entry>
         <xsl:map-entry key="'saviour'">savior</xsl:map-entry>
         <xsl:map-entry key="'Saviours'">savior</xsl:map-entry>
         <xsl:map-entry key="'saviours'">savior</xsl:map-entry>
         <xsl:map-entry key="'savours'">savor</xsl:map-entry>
         <xsl:map-entry key="'saying'">
            <matches pattern="([Tt]he|spiritual|this|my) saying">saying</matches>
            <otherwise>say</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sayings'">saying</xsl:map-entry>
         <xsl:map-entry key="'seed'">seed</xsl:map-entry>
         <xsl:map-entry key="'seen'">see</xsl:map-entry>
         <xsl:map-entry key="'sense'">sense (n.)</xsl:map-entry>
         <xsl:map-entry key="'senses'">
            <matches pattern="it senses">sense (v.)</matches>
            <matches pattern="senses sensory">sense (v.)</matches>
            <otherwise>sense (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sensed'">sense (v.)</xsl:map-entry>
         <xsl:map-entry key="'sensing'">sense (v.)</xsl:map-entry>
         <xsl:map-entry key="'sent'">send</xsl:map-entry>
         <xsl:map-entry key="'Sheol'">sheol</xsl:map-entry>
         <xsl:map-entry key="'Shéol'">sheol</xsl:map-entry>
         <xsl:map-entry key="'St'">
            <matches pattern="( |^)St\. ">saint</matches>
            <otherwise>st</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'Scetis'">Scetis</xsl:map-entry>
         <xsl:map-entry key="'scourge'">scourge (n.)</xsl:map-entry>
         <xsl:map-entry key="'scourging'">scourge (v.)</xsl:map-entry>
         <xsl:map-entry key="'selves'">self</xsl:map-entry>
         <xsl:map-entry key="'shadow'">shadow (n.)</xsl:map-entry>
         <xsl:map-entry key="'shadowed'">shadow (v.)</xsl:map-entry>
         <xsl:map-entry key="'shaken'">shake</xsl:map-entry>
         <xsl:map-entry key="'shape'">
            <matches pattern="shape it">shape (v.)</matches>
            <otherwise>shape (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'shapes'">
            <matches pattern="(who|that) shapes">shape (v.)</matches>
            <otherwise>shape (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'shaping'">shape (v.)</xsl:map-entry>
         <xsl:map-entry key="'share'">
            <matches pattern="(your| a) share">share (n.)</matches>
            <otherwise>share (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sheaves'">sheaf</xsl:map-entry>
         <xsl:map-entry key="'shot'">shoot</xsl:map-entry>
         <xsl:map-entry key="'shown'">show</xsl:map-entry>
         <xsl:map-entry key="'silence'">silence (n.)</xsl:map-entry>
         <xsl:map-entry key="'silenced'">silence (v.)</xsl:map-entry>
         <xsl:map-entry key="'silencing'">silence (v.)</xsl:map-entry>
         <xsl:map-entry key="'sin'">
            <matches pattern="to sin">sin (v.)</matches>
            <otherwise>sin (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sleep'">
            <matches pattern="(who|that|his sons) sleep">sleep (v.)</matches>
            <otherwise>sleep (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sleeping'">sleep (v.)</xsl:map-entry>
         <xsl:map-entry key="'slept'">sleep (v.)</xsl:map-entry>
         <xsl:map-entry key="'sold'">sell</xsl:map-entry>
         <xsl:map-entry key="'sought'">seek</xsl:map-entry>
         <xsl:map-entry key="'sound'">
            <matches pattern="safe and sound">sound (adj.)</matches>
            <otherwise>sound (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sown'">sow</xsl:map-entry>
         <xsl:map-entry key="'spake'">speak</xsl:map-entry>
         <xsl:map-entry key="'spoke'">speak</xsl:map-entry>
         <xsl:map-entry key="'spoken'">speak</xsl:map-entry>
         <xsl:map-entry key="'spring'">
            <matches pattern="spring and summer">spring (n.)</matches>
            <otherwise>spring (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'struggle'">
            <matches pattern="(its|monk.s|the|our|common|glorious) struggle">struggle (n.)</matches>
            <otherwise>struggle (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'study'">
            <matches pattern="of study">study (n.)</matches>
            <otherwise>study (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'struggles'">struggle</xsl:map-entry>
         <xsl:map-entry key="'subject'">
            <matches pattern="(the|same|living|this) subject">subject (n.)</matches>
            <otherwise>subject (adj.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'suffering'">
            <matches pattern="one suffering from">suffer</matches>
            <otherwise>suffering</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'sufferings'">suffering</xsl:map-entry>
         <xsl:map-entry key="'supposing'">suppose</xsl:map-entry>
         <xsl:map-entry key="'theologiké'">theologike</xsl:map-entry>
         <xsl:map-entry key="'taken'">take</xsl:map-entry>
         <xsl:map-entry key="'taste'">
            <matches pattern="the taste">taste (n.)</matches>
            <matches pattern="taste, flavours">taste (n.)</matches>
            <otherwise>taste (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'taught'">teach</xsl:map-entry>
         <xsl:map-entry key="'teaching'">
            <matches pattern="(the|spiritual) teaching">teaching</matches>
            <otherwise>teach</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'tear'">tear (v.)</xsl:map-entry>
         <xsl:map-entry key="'tears'">
            <matches pattern="tears the">tear (v.)</matches>
            <otherwise>tear (n.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'tearing'">tear (v.)</xsl:map-entry>
         <xsl:map-entry key="'teachings'">teaching</xsl:map-entry>
         <xsl:map-entry key="'teeth'">tooth</xsl:map-entry>
         <xsl:map-entry key="'thieves'">thief</xsl:map-entry>
         <xsl:map-entry key="'thought'">
            <matches pattern="it is thought">think</matches>
            <matches pattern="I thought was">think</matches>
            <otherwise>thought</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'threw'">throw</xsl:map-entry>
         <xsl:map-entry key="'Tim'">
            <matches pattern="\dTim"/>
            <otherwise>tim</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'time'">
            <matches pattern="mean time"/>
            <otherwise>time</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'told'">tell</xsl:map-entry>
         <xsl:map-entry key="'took'">take</xsl:map-entry>
         <xsl:map-entry key="'touch'">
            <matches pattern="nor touch">touch (n.)</matches>
            <otherwise>touch (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'towards'">toward</xsl:map-entry>
         <xsl:map-entry key="'thumikos'">thumikon</xsl:map-entry>
         <xsl:map-entry key="'timing'">timing</xsl:map-entry>
         <xsl:map-entry key="'travelled'">travel</xsl:map-entry>
         <xsl:map-entry key="'travelling'">travel</xsl:map-entry>
         <xsl:map-entry key="'triang'">
            <matches pattern="triang\[ular">triangular</matches>
            <otherwise>triang</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'ular'">
            <matches pattern="triang\[ular"/>
            <otherwise>ular</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'trinity'">Trinity</xsl:map-entry>
         <xsl:map-entry key="'trouble'">
            <matches pattern="(the|of) trouble">trouble (n.)</matches>
            <otherwise>trouble (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'troubles'">trouble</xsl:map-entry>
         <xsl:map-entry key="'understood'">understand</xsl:map-entry>
         <xsl:map-entry key="'use'">
            <matches pattern="([Mm]ake|their|the|of|appropriate) use">use (n.)</matches>
            <otherwise>use (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'varied'">
            <matches pattern="are varied">vary</matches>
            <otherwise>varied</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'well'">
            <matches pattern="(deep|the) well">well (n.)</matches>
            <matches pattern="(gets|be) well">well (adj.)</matches>
            <otherwise>well (adv.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'will'">
            <matches pattern="(the|free) will">will</matches>
            <otherwise/>
         </xsl:map-entry>
         <xsl:map-entry key="'went'">go</xsl:map-entry>
         <xsl:map-entry key="'wilt'">will</xsl:map-entry>
         <xsl:map-entry key="'wives'">wife</xsl:map-entry>
         <xsl:map-entry key="'woke'">wake</xsl:map-entry>
         <xsl:map-entry key="'women'">woman</xsl:map-entry>
         <xsl:map-entry key="'work'">
            <matches pattern="([tT]he|manual|hard|proper|[hH]is|artist.s\]|at|each|your) work">work (n.)</matches>
            <matches pattern="the .work">work (n.)</matches>
            <matches pattern="EAger for work">work (n.)</matches>
            <otherwise>work (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'works'">
            <matches pattern="([tT]he|are|his|in) works">work (n.)</matches>
            <otherwise>work (v.)</otherwise>
         </xsl:map-entry>
         <xsl:map-entry key="'worshiped'">worship (v.)</xsl:map-entry>
         <xsl:map-entry key="'worshiping'">worship (v.)</xsl:map-entry>
         <xsl:map-entry key="'written'">write</xsl:map-entry>
         <xsl:map-entry key="'wrong'">wrong (n.)</xsl:map-entry>
         <xsl:map-entry key="'wrongs'">wrong (n.)</xsl:map-entry>
         <xsl:map-entry key="'wronged'">wrong (v.)</xsl:map-entry>
         <xsl:map-entry key="'wrote'">write</xsl:map-entry>
      </xsl:map>
   </xsl:variable>

</xsl:stylesheet>
